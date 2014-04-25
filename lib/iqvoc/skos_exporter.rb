require 'iq_rdf'

module Iqvoc
  class SkosExporter
    include RdfHelper
    include ApplicationHelper # necessary to use render_concept helper
    include Rails.application.routes.url_helpers

    def initialize(file_path, type, default_namespace_url, logger = Rails.logger)
      default_url_options[:host] = default_namespace_url

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

      start = Time.now
      @logger.info 'Starting export...'
      @logger.info "file_path = #{@file_path}"
      @logger.info "type = #{@type}"

      # namespaces
      @logger.info 'Exporting namespaces...'
      document = IqRdf::Document.new
      Iqvoc.default_rdf_namespace_helper_methods.each do |meth|
        document.namespaces(send(meth))
      end
      @logger.info 'Finished exporting namespaces.'


      # colections
      @logger.info 'Exporting collections...'
      collections = Iqvoc::Collection.base_class.order("id")
      collections.each do |collection|
        render_collection(document, collection)
      end
      @logger.info "Finished exporting collections (#{collections.size} collections exported)."

      # concepts
      @logger.info "Exporting concepts..."
      concepts = Iqvoc::Concept.base_class.published.order("id")
      concepts.each do |concept|
        render_concept(document, concept, true)
      end
      @logger.info "Finished exporting concepts (#{concepts.size} concepts exported)."

      # saving export to disk
      @logger.info "Saving export to '#{Rails.root.join(@file_path).to_s}'"
      save_file(@file_path, @type, document)

      done = Time.now
      @logger.info "Export Job finished in #{(done - start).to_i} seconds."

      ActiveSupport.run_load_hooks(:skos_exporter_after_export, self)
    end


    def save_file(file_path, type, content)
      begin
        file = File.open(Rails.root.join(file_path).to_s, "w")
        content = serialize_rdf(content, type)
        file.write(content)
      rescue IOError => e
        # some error occur
        # e.g not writable
      ensure
        file.close unless file == nil
      end
    end

    def serialize_rdf(document, type)
      if type == 'xml'
        document.to_xml
      elsif type == 'ttl'
        document.to_turtle
      else
        document.to_ntriples
      end
    end

    ActiveSupport.run_load_hooks(:skos_exporter, self)
  end
end
