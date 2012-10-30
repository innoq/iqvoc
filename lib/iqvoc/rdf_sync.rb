# encoding: UTF-8

require 'iq_triplestorage/virtuoso_adaptor'

class Iqvoc::RDFSync
  delegate :url_helpers, :to => "Rails.application.routes"

  def initialize(base_url, target_host, *args)
    @base_url = base_url
    @target_host = target_host
    options = args.extract_options!
    @target_port = options[:port]
    @username = options[:username]
    @password = options[:password]
    @batch_size = options[:batch_size]
    @view_context = options[:view_context] # XXX: not actually optional
    raise(ArgumentError, "missing view context") unless @view_context # XXX: smell (see above)
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
          :host => URI.parse(@base_url).host, :format => nil, :lang => nil)
      memo[graph_uri] = serialize(record)
      memo
    end

    adaptor = IqTriplestorage::VirtuosoAdaptor.new(@target_host, @target_port,
        @username, @password)
    return adaptor.batch_update(data)
  end

  def serialize(record)
    # while this method is really fugly, iQvoc essentially requires us to mock a
    # view in order to get to the RDF serialization

    doc = IqRdf::Document.new(@base_url)
    Iqvoc.default_rdf_namespace_helper_methods.each do |meth|
      doc.namespaces(@view_context.send(meth))
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
      self.class.candidates(klass).find_in_batches(:batch_size => @batch_size) do |records|
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
    base_url = root_url(:lang => nil) # XXX: brittle in the face of future changes?

    host = URI.parse(Iqvoc.config["triplestore_url"])
    port = host.port
    host.port = 80 # XXX: hack to remove port from serialization
    host = host.to_s

    return Iqvoc::RDFSync.new(base_url, host, :port => port,
        :username => Iqvoc.config["triplestore_username"].presence,
        :password => Iqvoc.config["triplestore_password"].presence,
        :view_context => view_context) # fugly, but necessary; cf. RDFSync#serialize
  end

end
