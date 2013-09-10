require 'faraday'
require 'json'

class IqvocAdaptor
  attr_reader :name, :conn

  QUERY_TYPES = %w(exact contains ends_with begins_with)

  def initialize(name, host = nil)
    @name = name
    @host = host || config(:host)

    @conn = Faraday.new(:url => @host) do |builder|
      builder.use Faraday::Response::Logger if Rails.env.development?
      builder.use Faraday::Adapter::NetHttp
    end
  end

  def search(query, params = {})
    query_type = params.delete(:query_type)
    query_type = "begins_with" unless QUERY_TYPES.include?(query_type)

    languages = params.delete(:languages) || [I18n.locale]
    languages = Array.wrap(languages).flatten.join(",")

    response = conn.get do |req|
      req.url "/search.html"
      req.params["q"]   = CGI.unescape(query)
      req.params["qt"]  = query_type
      req.params["l"]   = languages
      req.params["for"] = "concept"
      req.params["t"]   = "labeling-skos-base"
      req.params["layout"] = 0
    end

    response.body
  end

  def config(key)
    config = ::Iqvoc.config["adaptors.iqvoc"]
    config.symbolize_keys!
    if config.has_key?(name) && config[name]
      return config[name][key]
    else
      raise "Adaptor configuration is missing '#{name}'."
    end
  end
end
