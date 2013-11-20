class Dataset::Adaptors::Iqvoc::HTTPAdaptor
  attr_reader :url

  def initialize(url)
    @url = url
    @conn = Faraday.new(:url => url) do |conn|
      #conn.use Faraday::Response::Logger if Rails.env.development?
      conn.adapter Faraday.default_adapter
    end
  end

  def http_get(path, redirect_count = 0)
    begin
      response = @conn.get(path)
    rescue Faraday::Error::ConnectionFailed,
        Faraday::Error::ResourceNotFound,
        Faraday::Error::TimeoutError => e
      Rails.logger.warn("HTTP error while querying remote source #{path}: #{e.message}")
      return nil
    end

    if response.status == 302 && redirect_count < 3
      response = http_get(response.headers["location"], redirect_count + 1)
    end

    response
  end
end
