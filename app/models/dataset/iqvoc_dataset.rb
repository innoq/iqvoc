require 'linkeddata'

class Dataset::IqvocDataset
  attr_reader :name, :url

  def initialize(url)
    @url = URI.parse(url)
    @repository = RDF::Repository.load(URI.join(url, 'dataset.rdf')) rescue nil
    @name = fetch_name
  end

  def to_s
    "#{name} (#{url})"
  end

  def search(params)
    Dataset::Adaptors::Iqvoc::SearchAdaptor.new(url).search(params)
  end

  def alphabetical_search(locale, prefix)
    Dataset::Adaptors::Iqvoc::AlphabeticalSearchAdaptor.new(url).search(locale, prefix)
  end

  def find_label(params)
    # Dataset::Adaptors::Iqvoc::LabelAdaptor.new.search(params)
  end

  private
  def fetch_name
    return 'unknown' if @repository.nil?

    void = RDF::Vocabulary.new('http://rdfs.org/ns/void#')
    query = RDF::Query.new({:dataset => {RDF.type => void.Dataset, RDF::DC.title => :title}})
    results = query.execute(@repository)

    return 'unknown' if results.empty?
    results.map { |solution| solution.title.to_s }.first
  end
end
