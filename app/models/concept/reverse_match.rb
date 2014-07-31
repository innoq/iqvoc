module Concept
  module ReverseMatch
    extend ActiveSupport::Concern

    def add_reverse_match(target_url, match_class)
      # FIXME: uggly url concatenation
      # target_url += '/add_match'

      conn = connection('http://0.0.0.0:3001/')

      response = conn.patch do |req|
        req.url 'en/concepts/fishing/add_match'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Referer'] = 'http://0.0.0.0:3000'

        # TODO: add inverse of match_class
        req.params['match_class'] = match_class
        # TODO: build uri dynamicly
        req.params['uri'] = 'http://0.0.0.0:3000/en/concepts/air_sports.html'
      end

      # binding.pry
    end

    def remove_reverse_match(target_url, match_class)
    end

    private

    def connection(url)
      Faraday.new(:url => url) do |faraday|
        faraday.response :logger # FIXME: log requests to STDOUT
        faraday.adapter  Faraday.default_adapter
      end
    end

  end
end
