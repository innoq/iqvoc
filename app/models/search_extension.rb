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

module SearchExtension
  extend ActiveSupport::Concern

  included do
    def self.multi_query(params = {})
      query_terms = params[:query].split(/\r\n/)
      results     = []
      query_terms.each do |term|
        results << { :query => term, :result => single_query(params.merge({:query => term})) }
      end
      results
    end

    def self.single_query(params = {})
      raise NotImplementedError.new("Implement self.single_query in your specific class (#{self.name}) that should be searchable!")
    end

    def self.supports_multi_query?
      false # FIXME Multipquerys don't work with will_paginate! Perhaps we schould remove them completely?
    end

    def self.forces_multi_query?
      false
    end

    def self.build_query_string(params = {})
      query_type = params[:query_type] || 'contains'

      query_str = case query_type
      when 'contains'
        "%#{params[:query]}%"
      when 'begins_with'
        "#{params[:query]}%"
      when 'ends_with'
        "%#{params[:query]}"
        # when 'regexp'
        #   params[:query]
      when 'exact'
        params[:query]
      else
        params[:query]
      end

      query_str
    end

  end

  def build_search_result_rdf(document, result)
    raise NotImplementedError.new("Implement build_search_result_rdf in your specific class (#{self.class.name}) that should be searchable!")
  end

end
