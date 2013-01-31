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

class Concept::Relation::SKOS::Broader::Base < Concept::Relation::SKOS::Base

  self.rdf_predicate = 'broader'

  def self.narrower_class
    Concept::Relation::SKOS::Narrower::Base
  end

  def self.reverse_relation_class
    self.narrower_class
  end

  def self.view_section(obj)
    'main'
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.narrower_editable
    !singular?
  end

  def self.relation_name
    'skos_broader'
  end

end
