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

class Collection::Member::Base < ActiveRecord::Base

  self.table_name = 'collection_members'

  class_attribute :rdf_namespace, :rdf_predicate
  self.rdf_namespace = nil
  self.rdf_predicate = nil
  
  belongs_to :collection, :class_name => 'Collection::Base'
  belongs_to :target, :class_name => 'Concept::Base'

end
