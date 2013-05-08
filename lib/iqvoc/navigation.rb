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

module Iqvoc
  module Navigation
    EXTENSION_INDEX = -3

    def self.items
      Iqvoc.navigation_items
    end

    def self.add(item)
      items.insert(EXTENSION_INDEX, item)
    end

    def self.add_grouped(item)
      setup_extension_group
      items[EXTENSION_INDEX][:items] << item
    end

    private
    # Setup an empty navigation group for extensions
    def self.setup_extension_group
      if !items[EXTENSION_INDEX][:items]
        items.insert(EXTENSION_INDEX, {
          :text  => proc { t("txt.views.navigation.extensions") },
          :items => []
        })
      end
    end
  end
end
