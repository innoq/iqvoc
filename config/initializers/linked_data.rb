require 'linkeddata'

# use faraday as http adapter in linked data gem instead of net/http. (e.g. RDF::Repository.load)
# Linkeddata net/http fallback strategy does not use existing http_proxy configuration
RDF::Util::File.http_adapter = RDF::Util::File::FaradayAdapter
