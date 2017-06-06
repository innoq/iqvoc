require 'linkeddata'
require 'timeout'

class Dataset::IqvocDataset
  DEFAULT_TIMEOUT = 5.freeze

  attr_reader :name, :url

  def initialize(url)
    @url = URI.parse(url)
    dataset_url = URI.join(@url.to_s + '/', 'dataset.rdf')

    @repository = Timeout::timeout(DEFAULT_TIMEOUT) do
      RDF::Repository.load(dataset_url)
    end

    @name = fetch_name
  end

  def to_s
    "#{name} (#{url})"
  end

  def search(params)
    Dataset::Adaptors::Iqvoc::SearchAdaptor.new(url).search(params)
  end

  def alphabetical_search(prefix, locale)
    Dataset::Adaptors::Iqvoc::AlphabeticalSearchAdaptor.new(url).search(prefix, locale)
  end

  def find_label(concept_url)
    Dataset::Adaptors::Iqvoc::LabelAdaptor.new(url).find(concept_url)
  end

  private
  def fetch_name
    return @url.to_s if @repository.nil?

    void = RDF::Vocabulary.new('http://rdfs.org/ns/void#')
    query = RDF::Query.new({ dataset: { RDF.type => void.Dataset, RDF::DC.title => :title } })
    results = Timeout::timeout(DEFAULT_TIMEOUT) do
      query.execute(@repository)
    end

    return @url.to_s if results.nil? || results.empty?
    results.map { |solution| solution.title.to_s }.first
  end
end
