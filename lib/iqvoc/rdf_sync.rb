# encoding: UTF-8

class Iqvoc::RDFSync
  delegate :url_helpers, to: 'Rails.application.routes'

  ADAPTORS = { # XXX: inappropriate?
    'virtuoso' => lambda do  |host_url, options|
      require 'iq_triplestorage/virtuoso_adaptor'
      return IqTriplestorage::VirtuosoAdaptor.new(host_url, options)
    end,
    'sesame' => lambda do |host_url, options|
      require 'iq_triplestorage/sesame_adaptor'
      host_url, _, repo = host_url.rpartition('/repositories/')
      if host_url.blank? || repo.blank?
       raise ArgumentError, 'missing repository in Sesame URL'
      end
      options[:repository] = repo
      return IqTriplestorage::SesameAdaptor.new(host_url, options)
    end
  }

  def initialize(base_url, target_url, options)
    @base_url = base_url
    @target_url = target_url
    @username = options[:username]
    @password = options[:password]
    @batch_size = options[:batch_size] || 100
    @view_context = options[:view_context] # XXX: not actually optional
    raise(ArgumentError, 'missing view context') unless @view_context # XXX: smell (see above)
  end

  def all # TODO: rename
    timestamp = Time.now
    errors = false

    gather_candidates do |records|
       success = sync(records, timestamp)
       errors = true unless success
    end

    return !errors
  end

  def sync(records, timestamp=nil)
    timestamp ||= Time.now

    success = push(records)
    if success
      records.each do |record|
        record.update_attribute(:rdf_updated_at, timestamp)
      end
    end

    return success
  end

  def push(records)
    data = records.inject({}) do |memo, record|
      graph_uri = url_helpers.rdf_url(record.origin,
          host: URI.parse(@base_url).host, format: nil, lang: nil)
      memo[graph_uri] = serialize(record)
      memo
    end

    adaptor_type = 'sesame' # XXX: hard-coded
    adaptor = ADAPTORS[adaptor_type].call(@target_url, username: @username,
        password: @password)
    return adaptor.batch_update(data)
  end

  def serialize(record)
    # while this method is really fugly, iQvoc essentially requires us to mock a
    # view in order to get to the RDF serialization

    doc = IqRdf::Document.new(@base_url)
    RdfNamespacesHelper.instance_methods.each do |meth|
      namespaces = @view_context.send(meth)
      doc.namespaces(namespaces) if namespaces.is_a?(Hash)
    end

    rdf_helper = Object.new.extend(RdfHelper)
    if record.is_a? Iqvoc::Concept.base_class
      rdf_helper.render_concept(doc, record)
    else # XXX: must be extensible
      raise NotImplementedError, "unable to render RDF for #{record.class}"
    end

    return doc.to_ntriples
  end

  # yields batches of candidates for synchronization
  def gather_candidates # TODO: rename
    Iqvoc::Sync.syncable_classes.each do |klass|
      self.class.candidates(klass).find_in_batches(batch_size: @batch_size) do |records|
        yield records
      end
    end
  end

  # returns one or multiple ActiveRecord::RelationS, depending on whether
  # `klass` is provided
  def self.candidates(klass=nil)
    return klass ? klass.published.unsynced :
        Iqvoc::Sync.syncable_classes.map { |klass| candidates(klass) }
  end
end

module Iqvoc::RDFSync::Helper # TODO: rename -- XXX: does not belong here!?
  def triplestore_syncer
    base_url = root_url(lang: nil) # XXX: brittle in the face of future changes?

    return Iqvoc::RDFSync.new(base_url, Iqvoc.config['triplestore.url'],
        username: Iqvoc.config['triplestore.username'].presence,
        password: Iqvoc.config['triplestore.password'].presence,
        view_context: view_context) # fugly, but necessary; cf. RDFSync#serialize
  end
end
