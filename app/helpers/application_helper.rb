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

module ApplicationHelper

  # expects an array of hashes with the following members:
  # :content - usually a navigation link
  # :active - a function determining if the respective item is currently active
  # :authorized? - an optional function determining whether the respective item
  #     is available to the current user (defaults to true)
  def nav_items(items)
    items.map { |item|
      if (not item[:authorized?]) || item[:authorized?].call
        content_tag "li", item[:content].call,
            :class => ("active" if item[:active?].call)
      end
    }.join.html_safe
  end

  def iqvoc_default_rdf_namespaces
    Iqvoc.rdf_namespaces.merge({
        :default => root_url(:format => nil, :lang => nil, :trailing_slash => true).gsub(/\/\/$/, "/"), # gsub because of a Rails bug :-(
        :coll => collections_url(:trailing_slash => true, :lang => nil, :format => nil),
        :schema => controller.schema_url(:format => nil, :anchor => "", :lang => nil)
      })
  end

  def options_for_language_select(selected = nil)
    locales_collection = Iqvoc.available_languages.map { |l| [l, l] }

    options_for_select(locales_collection, selected)
  end

  def user_details(user)
    "#{user.name} (#{user.telephone_number})"
  end

  # Formats a list ob items or returns a remark if no items where given
  def item_listing(items, &block)
    return content_tag :p, "-", :class => 'term-unavailable' if items.empty?

    content_tag :ul, :class => "entity_list" do
      items.map do |item|
        content_tag :li, :class => (items.last == item ? "last-child" : "") do
          block.call(item)
        end
      end.join("\n").html_safe
    end
  end

  def error_messages_for(object)
    if object.errors.any?
      content_tag :ul, :class => "flash_error error_list" do
        object.errors.full_messages.each do |msg|
          concat(content_tag(:li, msg))
        end
      end
    end
  end

end
