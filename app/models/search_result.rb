class SearchResult
  class MetaInformation
    attr_reader :key, :value

    def initialize(key, value)
      @key = key
      @value = value
    end
  end

  attr_reader :label, :host, :path, :meta
  attr_accessor :body

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
