require 'faraday'
require 'nokogiri'
require 'linkeddata'

class IqvocSearchAdaptor
  attr_reader :name, :url

  def initialize(url)
    @url = URI.parse(url)
    @repository = RDF::Repository.load(URI.join(url, 'dataset.rdf')) rescue nil
    @results = nil

    @conn = Faraday.new(:url => @url) do |builder|
      builder.use Faraday::Response::Logger if Rails.env.development?
      builder.use Faraday::Adapter::NetHttp
    end

    @name = fetch_name
  end

  def search(raw_params = {})
    languages = raw_params.fetch(:languages, I18n.locale)
    languages = Array.wrap(languages).flatten.join(",")

    params = {
      :q => raw_params[:q],
      :t => raw_params[:t],
      :l => languages,
      :c => raw_params[:c],
      :qt => raw_params[:qt],
      :page => 1 # hard code the first page as we need to follow pagination links
    }

    fetch_results('/search.html', params)
    @results
  end

  def fetch_results(url, params = {})
    begin
      response = @conn.get(url, params)
      @results ||= []
      @results += extract_results(response.body)
      while more = @doc.at_css('a[rel=next]')
        fetch_results(more[:href], {})
      end
    rescue Faraday::Error::ConnectionFailed,
      Faraday::Error::ResourceNotFound,
      Faraday::Error::TimeoutError => e
        Rails.logger.warn("HTTP error while querying remote source #{url}: #{e.message}")
        return nil
    end
  end

  def extract_results(html)
    @doc = Nokogiri::HTML(html)

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

  def to_s
    "#{name} (#{url})"
  end
end
