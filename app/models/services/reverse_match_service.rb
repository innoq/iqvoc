module Services
  class ReverseMatchService
    include Rails.application.routes.url_helpers
    #include Iqvoc::Application.routes.url_helpers
    def initialize(host = nil, port = nil)
      @host = host
      @port = port
    end 

    def add(origin, target_url, match_class)
      # TODO: Error Handling
      conn = connection(target_url, { accept: 'application/json' })
      response = conn.get
      link = response.body['links'].detect { |h| h['rel'] == 'add_match' }
      url = link['href']
      method = link['method']

      # TODO: Error Handling
      conn = connection(url, { content_type: 'application/json', referer: root_url(host: @host, port: @port) })
      response = conn.send(method) do |req|
        req.params['match_class'] = match_class
        req.params['uri'] = rdf_url(origin, host: @host, port: @port, format: :json) 
      end
    end

    def remove(origin, target_url, match_class)
    end

    private

    def connection(url, headers = {})
      Faraday::Connection.new(url: url, headers: headers) do |builder|
        builder.use FaradayMiddleware::ParseJson
        builder.use FaradayMiddleware::FollowRedirects, limit: 5
        builder.adapter Faraday.default_adapter
      end
    end
  end
end
