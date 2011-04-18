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

class ChangeOriginLengths < ActiveRecord::Migration
  def self.up
    change_column :concepts, :origin, :string, :limit => 4000
    change_column :labels, :origin, :string, :limit => 4000
  end

  def self.down
    change_column :concepts, :origin, :string, :limit => 255
    change_column :labels, :origin, :string, :limit => 255
  end
end