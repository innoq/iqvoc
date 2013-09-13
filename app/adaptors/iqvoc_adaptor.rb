require 'faraday'
require 'nokogiri'

class IqvocAdaptor
  attr_reader :url

  QUERY_TYPES = %w(exact contains ends_with begins_with)

  def initialize(url)
    @url = url
    @doc = nil
    @response = nil

    @conn = Faraday.new(:url => @url) do |builder|
      builder.use Faraday::Response::Logger if Rails.env.development?
      builder.use Faraday::Adapter::NetHttp
    end
  end

  def search(query, params = {})
    query_type = params.fetch(:query_type, "begins_with")
    query_type = "begins_with" unless QUERY_TYPES.include?(query_type)

    languages = params.fetch(:languages, I18n.locale)
    languages = Array.wrap(languages).flatten.join(",")

    response = @conn.get do |req|
      req.url "/search.html"
      req.params["q"]   = CGI.unescape(query)
      req.params["qt"]  = query_type
      req.params["l"]   = languages
      req.params["for"] = "concept"
      req.params["t"]   = "labeling-skos-base"
      req.params["layout"] = 0
    end

    @response = response.body

    extract_results
  end

  def extract_results
    @doc = Nokogiri::HTML(@response)

    @doc.css('.search-result').map do |result|
      link = result.at_css('.search-result-link')
      label, path = link.text, link['data-resource-path']
      SearchResult.new(url, path, label)
    end
  end
end
