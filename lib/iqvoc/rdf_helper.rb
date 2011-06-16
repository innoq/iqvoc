# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Iqvoc
  # TODO: The whole class should move to umt because it highly proprietary
  # (and also has the wrong name because it only deals with "turtle").
  # TODO: The term "Helper" is misleading.
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
