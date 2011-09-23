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

class Match::Base < ActiveRecord::Base

  set_table_name 'matches'

  class_attribute :rdf_namespace, :rdf_predicate
  self.rdf_namespace = nil
  self.rdf_predicate = nil

  # ********** Associations

  belongs_to :concept, :class_name => "Concept::Base", :foreign_key => 'concept_id'

  # ********** Validations

  validate do |m|
    begin
      URI.parse(m.value)
    rescue URI::InvalidURIError => e
      errors.add(:value, "Not a valid url")
    end
  end

  # ********** Methods

  def self.view_section(obj)
    "matches"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/match/base"
  end

  def self.edit_partial_name(obj)
    "partials/match/edit_base"
  end

end
