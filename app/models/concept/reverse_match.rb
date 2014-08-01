module Concept
  module ReverseMatch
    extend ActiveSupport::Concern

    def add_reverse_match(target_url, match_class)
      
      # TODO: Error Handling
      conn = connection(target_url, { accept: 'application/json' })
      response = conn.get

      link = response.body['links'].detect {|h| h['rel'] == 'add_match' }
      url = link['href']
      method = link['method']

      # TODO: Error Handling
      conn = connection(url, {content_type: 'application/json', referer: 'http://0.0.0.0:3000'})
      response = conn.patch do |req|
        req.params['match_class'] = match_class
        req.params['uri'] = 'http://0.0.0.0:3000/en/concepts/air_sports.html'
      end
    end

    def remove_reverse_match(target_url, match_class)
    end

    private

    def connection(url, headers={})
      Faraday::Connection.new( url: url, headers: headers) do |builder|
        builder.use FaradayMiddleware::ParseJson
        builder.use FaradayMiddleware::FollowRedirects, limit:5
        builder.adapter Faraday.default_adapter
      end
    end

  end
end
