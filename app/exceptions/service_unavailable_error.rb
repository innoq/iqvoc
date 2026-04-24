class ServiceUnavailableError < StandardError
  attr_reader :url

  def initialize(message, url)
    @url = url
    super(message)
  end
end
