require 'iq_rdf'
require 'fileutils'

module Iqvoc
  class SkosExporter
    include RdfHelper # necessary to use render_concept helper
    include RdfNamespacesHelper
    include Rails.application.routes.url_helpers

    def initialize(file_path, type, default_namespace_url, logger = Rails.logger)
      default_url_options[:host] = default_namespace_url

      @file_path = file_path
      @type = type
      @logger = logger
      @document = IqRdf::Document.new

      unless ['ttl', 'nt', 'xml'].include? @type
        raise "Iqvoc::SkosExporter: Unknown rdf serialization. Parameter 'type' should be 'ttl' (Turtle), 'nt' (N-Triples) or 'xml' (RDF-XML)."
      end

      unless @file_path.is_a?(String)
        raise "Iqvoc::SkosExporter#export: Parameter 'file' should be a String."
      end

    end

    def run
      export
    end

    private

    def export
      ActiveSupport.run_load_hooks(:rdf_export_before, self)

      start = Time.now
      @logger.info 'Starting export...'
      @logger.info "file_path = #{@file_path}"
      @logger.info "type = #{@type}"

      # add export data
      add_namespaces(@document)
      add_collections(@document)
      add_concepts(@document)

      ActiveSupport.run_load_hooks(:rdf_export_before_save, self)

      # saving export to disk
      save_file(@file_path, @type, @document)

      done = Time.now
      @logger.info "Export Job finished in #{(done - start).to_i} seconds."

      ActiveSupport.run_load_hooks(:rdf_export_after, self)
    end

    def add_namespaces(document)
      @logger.info 'Exporting namespaces...'

      RdfNamespacesHelper.instance_methods.each do |meth|
        namespaces = send(meth)
        document.namespaces(namespaces) if namespaces.is_a?(Hash)
      end

      @logger.info 'Finished exporting namespaces.'
    end

    def add_collections(document)
      @logger.info 'Exporting collections...'

      offset = 0
      while true
        collections = Iqvoc::Collection.base_class.order("id").limit(100).offset(offset)
        limit = collections.size < 100 ? collections.size : 100
        break if collections.size == 0

        # Todo: Preloading???
        collections.each do |collection|
          render_collection(document, collection)
        end

        @logger.info "Collections #{offset+1}-#{offset+limit} exported."
        offset += collections.size # Size is important!
      end

      @logger.info "Finished exporting collections (#{offset} collections exported)."
    end

    def add_concepts(document)
      @logger.info "Exporting concepts..."

      offset = 0
      while true
        concepts = Iqvoc::Concept.base_class.published.order("id").limit(100).offset(offset)
        limit = concepts.size < 100 ? concepts.size : 100
        break if concepts.size == 0

        # When in single query mode, AR handles ALL includes to be loaded by that
        # one query. We don't want that! So let's do it manually :-)
        ActiveRecord::Associations::Preloader.new.preload(concepts,
          Iqvoc::Concept.base_class.default_includes + [
              :matches,
              :collection_members,
              :notations,
              {:relations => :target, :labelings => :target, :notes => :annotations}
          ])

        concepts.each do |concept|
          render_concept(document, concept, true)
        end

        @logger.info "Concepts #{offset+1}-#{offset+limit} exported."
        offset += concepts.size # Size is important!
      end

      @logger.info "Finished exporting concepts (#{offset} concepts exported)."
    end

    def save_file(file_path, type, content)
      begin
        full_path = Rails.root.join(file_path).to_s

        @logger.info "Saving export to '#{Rails.root.join(@file_path).to_s}'"
        create_directory(full_path)
        file = File.open(full_path, "w")
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

    def serialize_rdf(document, type)
      if type == 'xml'
        document.to_xml
      elsif type == 'ttl'
        document.to_turtle
      else
        document.to_ntriples
      end
    end

  end
end
