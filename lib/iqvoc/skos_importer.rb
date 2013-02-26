require 'iqvoc/rdfapi'

module Iqvoc
  class SkosImporter

    def initialize(file, default_namespace_url, logger = Rails.logger)
      @logger = logger

      unless file.is_a?(File) || file.is_a?(Array)
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

      @seen_first_level_objects = {}
      @blank_nodes = {}

      @existing_origins = {} # To prevent the creation of first level objects we already have
      Iqvoc::RDFAPI::FIRST_LEVEL_OBJECT_CLASSES.each do |klass|
        klass.select('origin').all.each do |thing|
          @existing_origins[thing.origin] = klass
        end
      end

      import(file)
    end

    private

    def import(file)
      # Collect blank nodes
      file.each do |line|
        identify_blank_nodes(*extract_triple(line))
      end

      file.rewind if file.is_a?(IO)

      file.each do |line|
        import_first_level_objects(Iqvoc::RDFAPI::OBJECT_DICTIONARY, *extract_triple(line))
      end

      new_subjects = @seen_first_level_objects.dup # Remember the objects seen yet, because they are the ones to be published later

      file.rewind if file.is_a?(IO)
      file.each do |line|
        import_second_level_objects(Iqvoc::RDFAPI::PREDICATE_DICTIONARY, *extract_triple(line))
      end

      new_subjects.each do |id, subject|
        if subject.valid_with_full_validation?
          subject.publish
          subject.save!
        else
          @logger.warn "WARNING: Subject not valid: '#{subject.origin}'. Won't be published automatically."
        end
      end

    end

    def identify_blank_nodes(subject, predicate, object)
      if blank_node?(subject)
        @blank_nodes[subject] ||= []
        @blank_nodes[subject] << [predicate, object]
      end
    end

    def import_first_level_objects(types, subject, predicate, object)
      @logger.debug "types: #{types}"
      @logger.debug "predicate: #{predicate}"
      @logger.debug "subject: #{subject}"
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
          @seen_first_level_objects[origin] = types[object].create!(:origin => origin)
        end
      end

    end

    def import_second_level_objects(types, subject, predicate, object)
      return unless (subject =~ /^:(.*)$/ && types[predicate]) # We're not responsible for this

      # Load the subject and replace the string by the respective data object
      subject_origin = $1
      subject = load_first_level_object(subject_origin)
      unless subject
        @logger.warn "Iqvoc::SkosImporter: Couldn't find Subject with origin '#{subject_origin}. Skipping entry '#{subject} #{predicate} #{object}.'"
        return
      end

      # Load the data object for the object string if this is representing a thing in our domain
      if (object =~ /^:(.*)$/ && types[predicate])
        object_origin = $1
        object = load_first_level_object(object_origin)
        unless object
          @logger.warn "Iqvoc::SkosImporter: Couldn't find Object with origin '#{object_origin}. Skipping entry ':#{subject_origin} #{predicate} #{object}.'"
          return
        end
      end

      if blank_node?(object)
        object = @blank_nodes[object]
      end

      types[predicate].build_from_rdf(subject, predicate, object)
    end

    def load_first_level_object(origin)
      unless @seen_first_level_objects[origin]
        Iqvoc::RDFAPI::FIRST_LEVEL_OBJECT_CLASSES.each do |klass|
          @seen_first_level_objects[origin] = klass.by_origin(origin).last
          break if @seen_first_level_objects[origin]
        end
      end
      @seen_first_level_objects[origin]
    end

    def blank_node?(str)
      str.dup.to_s =~ /^_:.+/
    end

    def extract_triple(line)
      raise "'#{line}' doesn't look like valid ntriples data." unless line =~ /^(.*)\.\w*$/
      line = $1.squish

      triple = line.split(' ', 3) # The first one are uris the last can be a literal too

      triple.each do |e| # Do some fun with the uris and literals
        @prefixes.keys.each do |uri_prefix| # Use prefixes instead of full uris
          e.gsub! /<#{uri_prefix}([^>]*)>/ do |matches|
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

  end
end
