require 'iqvoc/rdfapi'

module Iqvoc
  class SkosImporter

    FIRST_LEVEL_OBJECT_CLASSES = [Iqvoc::Concept.base_class, Iqvoc::Collection.base_class]
    SECOND_LEVEL_OBJECT_CLASSES = Iqvoc::Concept.labeling_classes.keys +
        Iqvoc::Concept.note_classes +
        Iqvoc::Concept.relation_classes +
        Iqvoc::Concept.match_classes +
        Iqvoc::Concept.notation_classes +
        Iqvoc::Concept.additional_association_classes.keys +
        [Iqvoc::Concept.root_class] +
        [Iqvoc::Collection.member_class]

    def initialize(object, default_namespace_url, logger = Rails.logger, publish = true)
      @file = case object
                when File
                  File.open(object)
                when Array
                  object
                else
                  open(object)
              end

      @publish = publish

      @logger = logger

      unless @file.is_a?(File) || @file.is_a?(Array)
        raise "Iqvoc::SkosImporter#import: Parameter 'file' should be a File or an Array."
      end

      # Some general Namespaces to support in any case
      @prefixes = {
        "http://www.w3.org/2004/02/skos/core#" => "skos:",
        "http://www.w3.org/2008/05/skos#" => "skos:",
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#" => "rdf:",
        default_namespace_url => ":"
      }
      # Add the namespaces specified in the Iqvoc config
      Iqvoc.rdf_namespaces.each do |pref, uri|
        @prefixes[uri] = "#{pref.to_s}:"
      end

      @seen_first_level_objects = {} # Concept cache (don't load any concept twice from db)

      # Assign the default concept scheme singleton instance as a seen first level object upfront
      # in order to handle a missing scheme definition in ntriple data
      @seen_first_level_objects[Iqvoc::Concept.root_class.instance.origin] = Iqvoc::Concept.root_class.instance

      @new_subjects = [] # Concepts to be published later

      # Triples the importer doesn't understand immediately. Example:
      #
      #     :a skos:prefLabel "foo". # => What is :a? Remember this and try again later
      #     ....
      #     :a rdf:type skos:Concept # => Now I know :a, good I remembered it's prefLabel...
      @unknown_second_level_triples = []

      # Hash of arrays of arrays: { "_:n123" => [["pred1", "obj1"], ["pred2", "obj2"]] }
      @blank_nodes = {}

      @existing_origins = {} # To prevent the creation of first level objects we already have
      FIRST_LEVEL_OBJECT_CLASSES.each do |klass|
        klass.select('origin').load.each do |thing|
          @existing_origins[thing.origin] = klass
        end
      end
    end

    def run
      import @file
    end

    private

    def import(file)
      ActiveSupport.run_load_hooks(:skos_importer_before_import, self)

      start = Time.now

      first_level_types = {} # type identifier ("namespace:SomeClass") to Iqvoc class assignment hash
      FIRST_LEVEL_OBJECT_CLASSES.each do |klass|
        first_level_types["#{klass.rdf_namespace}:#{klass.rdf_class}"] = klass
      end
      second_level_types = {}
      SECOND_LEVEL_OBJECT_CLASSES.each do |klass|
        second_level_types["#{klass.rdf_namespace}:#{klass.rdf_predicate}"] = klass
      end

      file.each do |line|
        identify_blank_nodes(*extract_triple(line)) ||
            import_first_level_objects(first_level_types, *extract_triple(line)) ||
            import_second_level_objects(second_level_types, false, *extract_triple(line))
      end

      @logger.info "Computing 'forward' defined triples..."
      @unknown_second_level_triples.each do |s, p, o|
        import_second_level_objects(second_level_types, true, s, p, o)
      end

      first_import_step_done = Time.now
      @logger.info "Basic import done (took #{(first_import_step_done - start).to_i} seconds)."

      published = publish

      done = Time.now
      @logger.info "Publishing of #{published} subjects done (took #{(done - first_import_step_done).to_i} seconds). #{@new_subjects.count - published} are in draft state."
      puts "Imported #{published} published and #{@new_subjects.count - published} draft subjects in #{(done - start).to_i} seconds."
      puts "  First step took #{(first_import_step_done - start).to_i} seconds, publishing took #{(done - first_import_step_done).to_i} seconds."

      ActiveSupport.run_load_hooks(:skos_importer_after_import, self)
    end

    def publish
      published = 0
      if @publish
        @logger.info "Publishing #{@new_subjects.count} new subjects..."
        @new_subjects.each do |subject|
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
      if (predicate == "rdf:type" && types[object] && subject =~ /^:(.+)$/)
        # We've found a subject definition with a class we know and which is in our responsibility (":")
        origin = $1

        if (@existing_origins[origin])
          if (types[object] == @existing_origins[origin])
            @logger.info "Iqvoc::SkosImporter: Subject with origin '#{origin}' already exists. Skipping duplicate creation (should be no problem)."
          else
            @logger.warn "Iqvoc::SkosImporter: Subject with origin '#{origin} already exists but has another class (#{@existing_origins[origin]}) then the one I wanted to create (#{types[object]}). You seem to have a problem with your configuration!"
          end
        else
          @seen_first_level_objects[origin] = types[object].create! do |klass|
            klass.origin = origin
          end
          @new_subjects << @seen_first_level_objects[origin]
        end
        true
      else
        false
      end
    end

    def import_second_level_objects(types, final, subject, predicate, object)
      return unless (subject =~ /^:(.*)$/ && types[predicate]) # We're not responsible for this

      initial_triple = [subject, predicate, object]

      # Load the subject and replace the string by the respective data object
      subject_origin = $1
      subject = load_first_level_object(subject_origin)
      unless subject
        if final
          @logger.warn "Iqvoc::SkosImporter: Couldn't find Subject with origin '#{subject_origin}. Skipping entry '#{subject} #{predicate} #{object}.'"
        else
          @unknown_second_level_triples << initial_triple
        end
        return false
      end

      # Load the data object for the object string if this is representing a thing in our domain
      if (object =~ /^:(.*)$/ && types[predicate])
        object_origin = $1
        object = load_first_level_object(object_origin)
        unless object
          if final
            @logger.warn "Iqvoc::SkosImporter: Couldn't find Object with origin '#{object_origin}'. Skipping entry ':#{subject_origin} #{predicate} #{object}.'"
          else
            @unknown_second_level_triples << initial_triple
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
          @unknown_second_level_triples << initial_triple
          return false
        end
      end
      begin
        types[predicate].build_from_rdf(subject, predicate, object)
      rescue InvalidStringLiteralError => e
        warn e.message
      end
    end

    def load_first_level_object(origin)
      unless @seen_first_level_objects[origin]
        klass = @existing_origins[origin]
        if klass
          @seen_first_level_objects[origin] = klass.by_origin(origin).last
        end
      end

      @seen_first_level_objects[origin]
    end

    def blank_node?(str)
      str.dup.to_s =~ /^_:.+/
    end

    def extract_triple(line)
      raise "'#{line}' doesn't look like valid ntriples data." unless line =~ /^(.*)\.\s*$/
      line = $1.squish

      triple = line.split(' ', 3) # The first one are uris the last can be a literal too

      triple.each do |e| # Do some fun with the uris and literals
        @prefixes.keys.each do |uri_prefix| # Use prefixes instead of full uris
          e.gsub! /^<#{uri_prefix}([^>]*)>/ do |matches|
            @prefixes[uri_prefix] + $1.gsub(".", "_")
          end
        end
        e.squish!
        e.gsub!(/^:(.*)$/) do
          ":#{Iqvoc::Origin.new($1)}" # Force correct origins in the default namespace
        end
      end

      triple
    end

    ActiveSupport.run_load_hooks(:skos_importer, self)
  end

end
