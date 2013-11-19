class Dataset::Adaptors::Iqvoc::HTTPAdaptor
  attr_reader :url

  def initialize(url)
    @url = url
    @conn = Faraday.new(:url => url) do |builder|
      builder.use Faraday::Response::Logger if Rails.env.development?
      builder.use Faraday::Adapter::NetHttp
    end
  end
end
