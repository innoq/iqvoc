class SkosImporter
  class_attribute :first_level_object_classes, :second_level_object_classes
  self.first_level_object_classes = [
    Iqvoc::Concept.base_class,
    Iqvoc::Collection.base_class
  ]
  self.second_level_object_classes = Iqvoc::Concept.labeling_classes.keys +
    Iqvoc::Concept.note_classes +
    Iqvoc::Concept.relation_classes +
    Iqvoc::Concept.match_classes +
    Iqvoc::Concept.notation_classes +
    Iqvoc::Concept.additional_association_classes.keys +
    [Iqvoc::Concept.root_class] +
    [Iqvoc::Collection.member_class]

  def self.prepend_first_level_object_classes(args)
    self.first_level_object_classes.unshift(*args)
  end

  def initialize(object, default_namespace_url, logger = Rails.logger, publish = true, verbose = false)
    @file = case object
              when File
                File.open(object)
              when Array
                object
              else
                open(object)
            end

    @default_namespace_url = default_namespace_url
    @publish = publish
    @verbose = verbose
    @logger = logger

    unless @file.is_a?(File) || @file.is_a?(Array)
      raise "SkosImporter#import: Parameter 'file' should be a File or an Array."
    end

    # Some general Namespaces to support in any case
    @prefixes = {
      'http://www.w3.org/2004/02/skos/core#' => 'skos:',
      'http://www.w3.org/2008/05/skos#' => 'skos:',
      'http://www.w3.org/1999/02/22-rdf-syntax-ns#' => 'rdf:',
      default_namespace_url => ':'
    }
    # Add the namespaces specified in the Iqvoc config
    Iqvoc.rdf_namespaces.each do |pref, uri|
      @prefixes[uri] = "#{pref.to_s}:"
    end

    @seen_first_level_objects = {} # Concept cache (don't load any concept twice from db)

    # Assign the default concept scheme singleton instance as a seen first level object upfront
    # in order to handle a missing scheme definition in ntriple data
    @seen_first_level_objects[Iqvoc::Concept.root_class.instance.origin] = Iqvoc::Concept.root_class

    @new_subjects = {} # Concepts, collections, labels etc. to be published later

    # Triples the importer doesn't understand immediately. Example:
    #
    #     :a skos:prefLabel "foo". # => What is :a? Remember this and try again later
    #     ....
    #     :a rdf:type skos:Concept # => Now I know :a, good I remembered it's prefLabel...
    @unknown_second_level_triples = Set.new

    # Hash of arrays of arrays: { "_:n123" => [["pred1", "obj1"], ["pred2", "obj2"]] }
    @blank_nodes = {}

    @existing_origins = {} # To prevent the creation of first level objects we already have
    first_level_object_classes.each do |klass|
      klass.select('origin').load.each do |thing|
        @existing_origins[thing.origin] = klass
      end
    end
  end

  def run
    print_known_namespaces
    print_known_import_classes
    import @file
  end

  private

  def import(file)
    ActiveSupport.run_load_hooks(:skos_importer_before_import, self)

    start = Time.now

    @logger.info "default namespace: '#{@default_namespace_url}'"
    @logger.info "publish: '#{@publish}'"

    first_level_types = {} # type identifier ("namespace:SomeClass") to Iqvoc class assignment hash
    first_level_object_classes.each do |klass|
      first_level_types["#{klass.rdf_namespace}:#{klass.rdf_class}"] = klass
    end
    second_level_types = {}
    second_level_object_classes.each do |klass|
      second_level_types["#{klass.rdf_namespace}:#{klass.rdf_predicate}"] = klass
    end

    @logger.info 'SkosImporter: Importing triples...'
    file.each_with_index do |line, index|
      extracted_triple = *extract_triple(line)

      if @verbose && has_unknown_namespaces?(extracted_triple)
        @logger.warn "SkosImporter: Unknown namespaces. Skipping #{extracted_triple.join(' ')}"
      end

      unless has_valid_origin?(extracted_triple)
        @logger.warn "SkosImporter: Invalid origin. Skipping #{extracted_triple.join(' ')}"
        next
      end

      identify_blank_nodes(*extracted_triple) ||
        import_first_level_objects(first_level_types, *extracted_triple) ||
        import_second_level_objects(second_level_types, false, line)
    end

    # treeify blank nodes hash
    @blank_nodes.each do |origin, bnode_struct|
      tranform_blank_node(origin, bnode_struct)
    end

    @logger.info "Computing 'forward' defined triples..."
    @unknown_second_level_triples.each do |line|
      import_second_level_objects(second_level_types, true, line)
    end

    first_import_step_done = Time.now
    @logger.info "Basic import done (took #{(first_import_step_done - start).to_i} seconds)."

    published = publish

    done = Time.now
    @logger.info "Publishing of #{published} subjects done (took #{(done - first_import_step_done).to_i} seconds). #{@new_subjects.count - published} are in draft state."
    @logger.info "Imported #{published} published and #{@new_subjects.count - published} draft subjects in #{(done - start).to_i} seconds."
    @logger.info "First step took #{(first_import_step_done - start).to_i} seconds, publishing took #{(done - first_import_step_done).to_i} seconds."

    ActiveSupport.run_load_hooks(:skos_importer_after_import, self)
  end

  def publish
    published = 0
    # Respect order of first level classes configured in FIRST_LEVEL_OBJECTS
    # Example: XL labels have to be published before referencing concepts
    sorted_new_subjects = @new_subjects.sort_by do |origin, klass|
      first_level_object_classes.index(klass)
    end

    if @publish
      @logger.info "Publishing #{@new_subjects.count} new subjects..."

      sorted_new_subjects.each do |origin, klass|
        subject = klass.find_by(origin: origin)
        if subject.publishable?
          subject.publish!
          published += 1
        else
          @logger.warn "WARNING: Publishing failed! Subject ('#{subject.origin}') invalid: #{subject.errors.to_hash.inspect}"
        end
      end
    end
    published
  end

  def identify_blank_nodes(subject, predicate, object)
    if blank_node?(subject)
      @blank_nodes[subject] ||= []
      @blank_nodes[subject] << [predicate, object]
      true
    else
      false
    end
  end

  def import_first_level_objects(types, subject, predicate, object)
    if (predicate == 'rdf:type' && types[object] && subject =~ /^:(.+)$/)
      # We've found a subject definition with a class we know and which is in our responsibility (":")
      origin = $1

      if (@existing_origins[origin])
        if (types[object] == @existing_origins[origin])
          @logger.info "SkosImporter: Subject with origin '#{origin}' already exists. Skipping duplicate creation (should be no problem)."
        else
          @logger.warn "SkosImporter: Subject with origin '#{origin} already exists but has another class (#{@existing_origins[origin]}) then the one I wanted to create (#{types[object]}). You seem to have a problem with your configuration!"
        end
      else
        @logger.info "SkosImporter: Creating Subject: #{subject} #{predicate} #{object}" if @verbose
        # FIXME

        types[object].create do |klass|
          klass.origin = origin
        end
        @seen_first_level_objects[origin] = types[object]
        @new_subjects[origin] = types[object]
      end
      true
    else
      false
    end
  end

  def import_second_level_objects(types, final, line)
    subject, predicate, object = *extract_triple(line)

    return unless (subject =~ /^:(.*)$/ && types[predicate]) # We're not responsible for this

    # Load the subject and replace the string by the respective data object
    subject_origin = $1
    subject = load_first_level_object(subject_origin)
    unless subject
      if final
        @logger.warn "SkosImporter: Couldn't find Subject with origin '#{subject_origin}. Skipping entry '#{subject} #{predicate} #{object}.'"
      else
        @unknown_second_level_triples << line
      end
      return false
    end

    # Load the data object for the object string if this is representing a thing in our domain
    if (object =~ /^:(.*)$/ && types[predicate])
      object_origin = $1
      object = load_first_level_object(object_origin)
      unless object
        if final
          @logger.warn "SkosImporter: Couldn't find Object with origin '#{object_origin}'. Skipping entry ':#{subject_origin} #{predicate} #{object_origin}.'"
        else
          @unknown_second_level_triples << line
        end
        return false
      end
    end

    # If not in final mode every :my_concept :bla _:blank_node. triple should
    # be saved for final mode. Why? Example:
    #
    #    :a iqvoc:changeNote _:b01 # => I do not know know anything about the blank node now
    #    _:b01 dc:author "DHH"...
    #
    if blank_node?(object)
      if final
        object = @blank_nodes[object]
      else
        @unknown_second_level_triples << line
        return false
      end
    end
    begin
      types[predicate].build_from_rdf(subject, predicate, object)
    rescue Exception => e
      @logger.warn "#{e.class.name}: #{e.message}. Skipping entry ':#{subject} #{predicate} #{object}.'"
    end
  end

  def load_first_level_object(origin)
    unless @seen_first_level_objects[origin]
      klass = @existing_origins[origin]
      if klass
        @seen_first_level_objects[origin] = klass
      end
    end

    # FIXME: bang
    # FIXME: return something?
    if klass = @seen_first_level_objects[origin]
      klass.find_by!(origin: origin)
    end
  end

  def blank_node?(str)
    str.to_s =~ RDFAPI::BLANK_NODE_REGEXP
  end

  def extract_triple(line)
    raise "'#{line}' doesn't look like valid ntriples data." unless line =~ /^(.*)\.\s*$/
    line = $1.squish

    triple = line.split(' ', 3) # The first one are uris the last can be a literal too

    triple.each do |e| # Do some fun with the uris and literals
      @prefixes.keys.each do |uri_prefix| # Use prefixes instead of full uris
        e.gsub! /^<#{uri_prefix}([^>]*)>/ do |matches|
          @prefixes[uri_prefix] + $1.gsub('.', '_')
        end
      end
      e.squish!
    end
    triple
  end

  def has_unknown_namespaces?(triple)
    triple.each do |obj|
      return true if obj =~ /^<.*>$/
      break
    end
    false
  end

  def has_valid_origin?(triple)
    if blank_node?(triple.first)
      origin = triple.first
    else
      # strip out leading ':' for origin validation
      origin = triple.first[1..-1]
    end

    result = Origin.new(origin).valid?

    result
  end

  # if blank node contains another blank node,
  # move child blank node to his parent
  def tranform_blank_node(origin, bnode_struct)
    bnode_struct.each_index do |i|
      bnode_origin = bnode_struct[i][1] # only origin could contain another blank node
      if blank_node?(bnode_origin)
        bnode_child_struct = @blank_nodes[bnode_origin]
        bnode_struct[i][1] = bnode_child_struct # move to parent node
        tranform_blank_node(bnode_origin, bnode_child_struct)

        @blank_nodes.delete(bnode_origin) # remove old blank node
      end
    end
  end

  def print_known_namespaces
    @logger.info "Known namespaces:"
    @prefixes.each_with_index do |(uri, pref), i|
      @logger.info "\t #{i+1}: #{pref} => #{uri}"
    end
  end

  def print_known_import_classes
    @logger.info "Known first level classes:"
    first_level_object_classes.each_with_index do |floc, i|
      @logger.info "\t #{i+1}: #{floc.rdf_namespace}:#{floc.rdf_class} => #{floc.to_s}"
    end

    @logger.info "Known second level classes:"
    second_level_object_classes.each_with_index do |sloc, i|
      @logger.info "\t #{i+1}: #{sloc.rdf_namespace}:#{sloc.rdf_predicate} => #{sloc.to_s}"
    end
  end

  ActiveSupport.run_load_hooks(:skos_importer, self)
end
