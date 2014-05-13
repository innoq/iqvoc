require 'linkeddata'

class Dataset::IqvocDataset
  attr_reader :name, :url

  def initialize(url)
    @url = URI.parse(url)
    @repository = RDF::Repository.load(URI.join(url, 'dataset.rdf').to_s) rescue nil
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
    return 'unknown' if @repository.nil?

    void = RDF::Vocabulary.new('http://rdfs.org/ns/void#')
    query = RDF::Query.new({dataset: {RDF.type => void.Dataset, RDF::DC.title => :title}})
    results = query.execute(@repository)

    return 'unknown' if results.empty?
    results.map { |solution| solution.title.to_s }.first
  end
end
