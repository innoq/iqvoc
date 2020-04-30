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

class CreateCollectionLabels < ActiveRecord::Migration[4.2]
  def self.up
    create_table :collection_labels, force: true do |t|
      t.references :collection
      t.string :value
      t.string :language
      t.timestamps
    end

    add_index :collection_labels, :collection_id, name: 'ix_collection_labels_fk'
  end

  def self.down
    drop_table :collection_labels
  end
end
