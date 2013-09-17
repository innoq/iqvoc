require 'faraday'
require 'nokogiri'
require 'linkeddata'

class IqvocAdaptor
  attr_reader :name, :url

  QUERY_TYPES = %w(exact contains ends_with begins_with)

  def initialize(url)
    @url = URI.parse(url)
    @doc = nil
    @response = nil
    @repository = RDF::Repository.load(URI.join(url, 'void.rdf')) rescue nil

    @conn = Faraday.new(:url => @url) do |builder|
      builder.use Faraday::Response::Logger if Rails.env.development?
      builder.use Faraday::Adapter::NetHttp
    end

    @name = fetch_name
  end

  def search(query, params = {})
    query_type = params.fetch(:query_type, "begins_with")
    query_type = "begins_with" unless QUERY_TYPES.include?(query_type)

    languages = params.fetch(:languages, I18n.locale)
    languages = Array.wrap(languages).flatten.join(",")

    begin
      response = @conn.get do |req|
        req.url "/search.html"
        req.params["q"]   = CGI.unescape(query)
        req.params["qt"]  = query_type
        req.params["l"]   = languages
        req.params["for"] = params[:for]
        req.params["t"]   = params[:t]
        req.params["c"]   = params[:c]
        req.params["layout"] = 0
      end
    rescue
      Rails.logger.warn("HTTP error while querying remote source #{url}")
      return nil
    end

    @response = response.body

    extract_results
  end

  def extract_results
    @doc = Nokogiri::HTML(@response)

    @doc.css('.search-result').map do |element|
      link = element.at_css('.search-result-link')
      label, path = link.text, link['data-resource-path']
      result = SearchResult.new(url, path, label)

      if (meta = element.css('.search-result-meta > .search-result-value')) && meta.any?
        meta.each do |element|
          result.add_meta_information(element['data-key'], element.text)
        end
      end

      if body = element.at_css('.search-result-body')
        result.body = body.text
      end

      result
    end
  end

  def fetch_name
    return 'unknown' if @repository.nil?

    void = RDF::Vocabulary.new('http://rdfs.org/ns/void#')
    query = RDF::Query.new({:dataset => {RDF.type => void.Dataset, RDF::DC.title => :title}})
    results = query.execute(@repository)

    return 'unknown' if results.empty?
    results.map { |solution| solution.title.to_s }.first
  end
end
