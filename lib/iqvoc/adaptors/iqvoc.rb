require 'faraday'
require 'json'

module Iqvoc
  module Adaptors

    class Iqvoc
      attr_reader :name
      
      QUERY_TYPES = %w(exact contains ends_with begins_with)
      
      def initialize(name, host = nil)
        @name = name
        @host = host || config(:host)
        
        @conn = Faraday.new(:url => @host) do |builder|
          builder.use Faraday::Response::Logger if Rails.env.development?
          builder.use Faraday::Adapter::NetHttp
        end
      end
      
      def search(query, params = {})
        query_type = params.delete(:query_type)
        query_type = "begins_with" unless QUERY_TYPES.include?(query_type)
        
        languages = params.delete(:languages) || [I18n.locale]
        languages = Array.wrap(languages).flatten.join(",")
        
        response = conn.get do |req|
          req.url "/search.json"
          req.params["q"]   = CGI.unescape(query)
          req.params["qt"]  = query_type
          req.params["l"]   = languages
          req.params["for"] = "concept"
          req.params["t"]   = "labeling-skos-base"
        end
        
        response.body
      end
      
      private
      def conn; @conn; end
      
      def config(key)
        ::Iqvoc.config["adaptors.iqvoc.#{name.to_s.underscore}.#{key}"]
      end
    end

  end
end
