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

##
# Provides a basic API wrapping low-level iQvoc config operations
# on Iqvoc.navigation_items

module Navigation
  def self.items
    Iqvoc.navigation_items
  end

  def self.add(item, position = nil)
    if position
      items.insert(position, item)
    else
      items << item
    end
  end

  def self.add_grouped(item, position = nil)
    index = setup_extension_group(position)
    items[index][:items] << item
  end

  private
  # Setup an empty navigation group for extensions
  # Returns index for the new (or existing) group, so add_grouped
  # can use the index to insert it's item under the group
  def self.setup_extension_group(position)
    group = {
      text: proc { t('txt.views.navigation.extensions') },
      items: []
    }

    if position && !items[position][:items]
      items.insert(position, group)
    elsif position && items[position][:items]
      return position
    else
      items << group
    end

    items.index(group)
  end
end
