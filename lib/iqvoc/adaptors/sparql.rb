# encoding: UTF-8

require "rest_client"
require "json"
require "nokogiri"

module Iqvoc
  module Adaptors
    
    class Sparql
      attr_reader :endpoint_uri, :prefixes
      
      TEMPLATE = <<-SPARQL
        ##PREFIXES##

        SELECT ##SELECT## 
        WHERE {
          ##WHERE##
        }
        LIMIT ##LIMIT##
      SPARQL
      
      RESPONSE_FORMATS = {
        :json => "application/sparql-results+json",
        :xml  => "application/sparql-results+xml"
      }
      
      def initialize(endpoint_uri, options = {})
        @endpoint_uri = endpoint_uri
        @prefixes = {
          :rdfs => "http://www.w3.org/2000/01/rdf-schema#"
        }
        @format = options.delete(:format) || :json
        @query_string = nil
      end
      
      def query(conditions, options = {})
        @query_string = build_query(conditions, options)
        
        # return query
        
        RestClient.log = Logger.new(STDOUT)
        
        response = RestClient.get(@endpoint_uri, :params => {
          :query  => @query_string,
          :format => RESPONSE_FORMATS[@format],
        })
        
        parse(response)
      end
      
      private
      
      # _very_ naive implementation, misses string sanitization
      def build_query(conditions, options = {})
        select = options.delete(:select) || "*"
        limit = options.delete(:limit) || "50"
        prefixes = @prefixes.merge(options.delete(:prefixes) || {})

        query_string = TEMPLATE.
        gsub("##PREFIXES##", prefixes.map {|key, uri| "PREFIX #{key}: <#{uri}>" }.join("\n")).
        gsub("##SELECT##", select).
        gsub("##WHERE##", conditions.to_s).
        gsub("##LIMIT##", limit.to_s)

        query_string.strip
      end

      def parse(response)
        unless RESPONSE_FORMATS.has_key?(@format)
          raise(TypeError, "Invalid response format, use one of #{RESPONSE_FORMATS.keys.map{|key| ":#{key}"}.join(", ")}.")
        end

        doc = case @format
        when :json then JSON.parse(response)
        when :xml  then Nokogiri::XML(response)
        end

        doc
      end
    end
    
  end
end
