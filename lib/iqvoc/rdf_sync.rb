# encoding: UTF-8

require 'iq_triplestorage/virtuoso_adaptor'

class Iqvoc::RDFSync
  delegate :url_helpers, :to => "Rails.application.routes"

  def initialize(base_url, target_host, *args)
    @base_url = base_url
    @target_host = target_host
    options = args.extract_options!
    @target_port = options[:target_port]
    @username = options[:username]
    @password = options[:password]
    @batch_size = options[:batch_size]
  end

  def all # TODO: rename
    timestamp = Time.now
    errors = false

    gather_candidates do |records|
      success = sync(records)
      if success
        records.each do |record|
          record.update_attribute(:rdf_updated_at, timestamp)
        end
      else
        errors = true # XXX: too simplistic
      end
    end

    return !errors
  end

  def sync(records)
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
    doc = IqRdf::Document.new(@base_url)
    doc.namespaces Iqvoc.rdf_namespaces
    doc << record.build_rdf_subject(nil, nil) # XXX: not passing any arguments to see why they're at all necessary
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
