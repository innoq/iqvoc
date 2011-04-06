module Iqvoc
  class RdfHelper
  
    LITERAL_REGEXP = /"(.*)"@([a-zA-Z]{2})/
  
    NSMAP = {
      'rdf'  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      'skos' => "http://www.w3.org/2004/02/skos/core#",
      'owl'  => "http://www.w3.org/2002/07/owl#",
      'rdfs' => "http://www.w3.org/2000/01/rdf-schema#" }

    def self.extract_id(uri)
      uri =~ /([^\/]+)\/{0,1}$/
      $1
    end
  
    def self.is_literal_form?(str)
      str.match LITERAL_REGEXP
    end

    def self.quote_turtle_literal(val)
      if val.to_s.match(/^<.*>$/)
        val
      else
        "\"#{val}\""
      end
    end
  
    def self.split_literal(str)
      elements = str.scan(LITERAL_REGEXP).first
      @split_literal = { 
        :value    => elements[0].gsub(/\\"/, '"'), 
        :language => elements[1]
      }
      RAILS_DEFAULT_LOGGER.debug "@split_literal => #{@split_literal}"
      @split_literal
    end

    def self.to_xml_attribute_array
      res = {}
      NSMAP.each do |k,v|
        res["xmlns:#{k}"] = v
      end
      res
    end
  
  end
end
