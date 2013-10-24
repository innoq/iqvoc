require 'faraday'
require 'nokogiri'
require 'linkeddata'

class SearchAdaptor
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
