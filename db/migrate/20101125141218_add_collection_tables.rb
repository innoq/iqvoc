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

class AddCollectionTables < ActiveRecord::Migration
  def self.up
    create_table :collections, :force => true do |t|
    end

    create_table :collection_contents, :force => true do |t|
      t.integer :collection_id
      t.integer :concept_id
    end
  end

  def self.down
    drop_table :collections
    drop_table :collection_contents
  end
end
