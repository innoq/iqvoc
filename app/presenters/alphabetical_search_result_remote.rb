class AlphabeticalSearchResultRemote < AlphabeticalSearchResult
  def initialize(host, path, label, options = {})
    @host = host
    @path = path
    @label = label
    @definition = options[:definition]
    @definition_language = options[:definition_language]
    @additional_info = options[:additional_info]
  end

  def label
    if @additional_info.present?
      "#{@label} #{@additional_info}"
    else
      @label
    end
  end

  def path
    @path
  end

  def url
    URI.join(@host, @path).to_s
  end

  def definition?
    @definition.present?
  end

  def definition
    @definition
  end

  def definition_language
    @definition_language
  end

  def partial_name
    'concepts/alphabetical/search_result_remote'
  end
end
