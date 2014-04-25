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

      document = IqRdf::Document.new

      # add eport data
      load_and_export_namespaces(document)
      load_and_export_collections(document)
      load_and_export_concepts(document)

      # saving export to disk
      save_file(@file_path, @type, document)

      done = Time.now
      @logger.info "Export Job finished in #{(done - start).to_i} seconds."

      ActiveSupport.run_load_hooks(:skos_exporter_after_export, self)
    end

    def load_and_export_namespaces(document)
      @logger.info 'Exporting namespaces...'

      Iqvoc.default_rdf_namespace_helper_methods.each do |meth|
        document.namespaces(send(meth))
      end

      @logger.info 'Finished exporting namespaces.'
    end

    def load_and_export_collections(document)
      @logger.info 'Exporting collections...'

      offset = 0
      while true
        collections = Iqvoc::Collection.base_class.order("id").limit(100).offset(offset)
        break if collections.size == 0

        # Todo: Preloading???
        collections.each do |collection|
          render_collection(document, collection)
        end

        offset += collections.size # Size is important!
      end

      @logger.info "Finished exporting collections (#{collections.size} collections exported)."
    end

    def load_and_export_concepts(document)
      @logger.info "Exporting concepts..."

      offset = 0
      while true
        concepts = Iqvoc::Concept.base_class.published.order("id").limit(100).offset(offset)
        break if concepts.size == 0

        # When in single query mode, AR handles ALL includes to be loaded by that
        # one query. We don't want that! So let's do it manually :-)
        ActiveRecord::Associations::Preloader.new.preload(concepts,
          Iqvoc::Concept.base_class.default_includes + [
              :matches,
              :collection_members,
              :notations,
              {:relations => :target, :labelings => :target, :notes => :annotations}])

        concepts.each do |concept|
          render_concept(document, concept, true)
        end

        offset += concepts.size # Size is important!
      end

      @logger.info "Finished exporting concepts (#{concepts.size} concepts exported)."
    end

    def save_file(file_path, type, content)
      begin
        @logger.info "Saving export to '#{Rails.root.join(@file_path).to_s}'"
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
