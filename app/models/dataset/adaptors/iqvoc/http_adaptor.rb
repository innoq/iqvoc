require 'faraday'

class Dataset::Adaptors::Iqvoc::HTTPAdaptor
  DEFAULT_TIMEOUT = 5.freeze
  attr_reader :url

  def initialize(url)
    @url = url
    @conn = Faraday.new(url: url, request: { timeout: DEFAULT_TIMEOUT }) do |conn|
      #conn.use Faraday::Response::Logger if Rails.env.development?
      conn.adapter Faraday.default_adapter
    end
  end

  def http_get(path, redirect_count = 0)
    begin
      response = @conn.get(path)
    rescue Faraday::Error::ConnectionFailed,
        Faraday::Error::ResourceNotFound => e
      return failed_request(path)
    end

    if response.status == 404
      return failed_request(path)
    end

    if response.status == 302 && redirect_count < 3
      response = http_get(response.headers['location'], redirect_count + 1)
    end

    response
  end

  private
  def failed_request(path)
    Rails.logger.warn "HTTP error while querying remote source #{path}"
    return nil
  end
end
