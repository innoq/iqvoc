# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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

  def build_search_result_rdf(document, result)
    raise NotImplementedError.new("Implement build_search_result_rdf in your specific class (#{self.class.name}) that should be searchable!")
  end

  module ClassMethods
    def single_query(params = {})
      raise NotImplementedError.new("Implement self.single_query in your specific class (#{self.name}) that should be searchable!")
    end

    def build_query_string(params = {})
      query_str = params[:query].strip
      query_str = "%#{query_str}" if ['contains', 'ends_with'].include?(params[:query_type].to_s)
      query_str = "#{query_str}%" if ['contains', 'begins_with'].include?(params[:query_type].to_s)
      # Note that 'contains' will add an '%' to the beginning AND to the end

      query_str
    end
  end
end
