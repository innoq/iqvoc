class SearchResult
  attr_reader :label, :host, :path

  def initialize(host, path, label)
    @host = host
    @path = path
    @label = label
  end

end
