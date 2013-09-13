class SearchResult
  attr_reader :label, :host, :path

  def self.search_result_partial_name
    'partials/labeling/skos/search_resulte_remote'
  end

  def initialize(host, path, label, meta = {})
    @host = host
    @path = path
    @label = label
    @meta = meta
  end

  def url
    host + path
  end

end
