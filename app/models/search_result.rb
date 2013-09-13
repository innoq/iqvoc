class SearchResult
  class MetaInformation
    attr_reader :key, :value

    def initialize(key, value)
      @key = key
      @value = value
    end
  end

  attr_reader :label, :host, :path, :meta

  def self.search_result_partial_name
    'partials/labeling/skos/search_resulte_remote'
  end

  def initialize(host, path, label)
    @host = host
    @path = path
    @label = label
    @meta = []
  end

  def add_meta_information(key, value)
    @meta << MetaInformation.new(key, value)
  end

  def url
    host + path
  end

end
