require 'linkeddata'
require 'faraday/follow_redirects'

class Faraday2Adapter < RDF::Util::File::FaradayAdapter
  class << self
    def conn
      @conn ||= Faraday.new do |c|
        c.response :follow_redirects, limit: 5
        c.adapter Faraday.default_adapter
      end
    end
  end
end

# use faraday as http adapter in linked data gem instead of net/http. (e.g. RDF::Repository.load)
# Linkeddata net/http fallback strategy does not use existing http_proxy configuration
RDF::Util::File.http_adapter = Faraday2Adapter
