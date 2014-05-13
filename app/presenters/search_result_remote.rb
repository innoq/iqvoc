class SearchResultRemote
  class MetaInformation
    attr_reader :key, :value

    def initialize(key, value)
      @key = key
      @value = value
    end
  end

  attr_reader :label, :host, :path, :meta
  attr_accessor :body, :rdf_namespace, :rdf_predicate, :language

  def initialize(host, path, label)
    @host = host
    @path = path
    @label = label.to_s.squish
    @meta = []
  end

  def add_meta_information(key, value)
    @meta << MetaInformation.new(key, value)
  end

  def url
    host + path
  end

  def search_result_partial_name
    'search_results/search_result_remote'
  end

  def rdf_predicate_uri
    rdf_namespace.try(:+, rdf_predicate)
  end

  def build_rdf(document, subject)
    predicate = URI.parse(rdf_predicate_uri)
    value = body || label

    subject.build_full_uri_predicate(predicate, value, lang: language)
  end

  def build_search_result_rdf(document, result)
    result.Sdc::link(url)
    build_rdf(document, result)
  end

  def to_s
    @label
  end
end
