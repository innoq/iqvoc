require 'iq_rdf'
require 'fileutils'

module Iqvoc
  class SkosExporter
    include RdfHelper
    include ApplicationHelper
    include Rails.application.routes.url_helpers
    default_url_options[:host] = ::Rails.application.routes.default_url_options[:host]

    def initialize(file_path, type, logger = Rails.logger)
      @file_path = file_path
      @type = type

      @logger = logger

      unless @file_path.is_a?(String)
        raise "Iqvoc::SkosExporter#export: Parameter 'file' should be a String."
      end
    end

    def run
      export
    end

    private

    def export
      ActiveSupport.run_load_hooks(:skos_exporter_before_export, self)

      # Todo: register namespaces dynamically
      # Iqvoc.default_rdf_namespace_helper_methods.each do |meth|
      #   document.namespaces(send(meth))
      # end

      document = IqRdf::Document.new('http://0.0.0.0:3000/')
      document.namespaces :skos => 'http://www.w3.org/2008/05/skos#',
        :dct => 'http://purl.org/dc/terms/',
        :foaf => 'http://xmlns.com/foaf/spec/',
        :iqvoc => 'http://try.iqvoc.net/schema#',
        :owl => 'http://www.w3.org/2002/07/owl#',
        :rdf => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
        :rdfs => 'http://www.w3.org/2000/01/rdf-schema#',
        :schema => 'http://0.0.0.0:3000/schema#',
        :void => 'http://rdfs.org/ns/void#',
        :coll => 'http://0.0.0.0:3000/collections/'

      # load colections
      collections = Iqvoc::Collection.base_class.order("id")
      collections.each do |collection|
        render_collection(document, collection)
      end
      @logger.debug "Added collections (#{collections.size})"

      # load concepts
      concepts = Iqvoc::Concept.base_class.published.order("id")
      concepts.each do |concept|
        render_concept(document, concept, true)
      end
      @logger.debug "Added concepts (#{concepts.size})"

      save_file(@file_path, @type, document)

      ActiveSupport.run_load_hooks(:skos_exporter_after_export, self)
    end


    def save_file(file_path, type, content)
      begin
        create_directory(file_path)
        file = File.open(file_path, "w")
        content = serialize_rdf(content, type)
        file.write(content)
      rescue IOError => e
        # some error occur
        # e.g not writable
      ensure
        file.close unless file == nil
      end
    end

    def create_directory(file_path)
      dirname = File.dirname(file_path)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end

    end

    def serialize_rdf(document, type=:nt)
      if type.to_sym == :xml
        document.to_xml
      elsif type == :ttl
        document.to_turtle
      else
        document.to_ntriples
      end
    end

    ActiveSupport.run_load_hooks(:skos_exporter, self)
  end
end
