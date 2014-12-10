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

module NavigationHelper
  # expects an array of hashes with the following members:
  # :content - usually a navigation link
  # :active? - an optional function determining whether the respective item is
  #     currently active
  # :controller - an optional string, used instead of `active?` to check for a
  #     specific controller
  # :authorized? - an optional function determining whether the respective item
  #     is available to the current user (defaults to true)
  # :items - a list of hashes to be used as second-level navigation items
  def nav_items(items)
    items.map do |item|
      if !item.has_key?(:authorized?) || instance_eval(&item[:authorized?])
        if item[:items]
          content_tag :li, class: 'dropdown' do
            raw(link_to(element_value(item[:text]).html_safe +
                    content_tag(:i, nil, class: 'fa fa-fw fa-angle-down'), '#',
                    class: 'dropdown-toggle',
                    data: { toggle: 'dropdown' }) +
                content_tag(:ul,
                    item[:items].map { |i| nav_item(i) }.join.html_safe,
                    class: 'dropdown-menu'))
          end
        else
          nav_item(item)
        end
      end
    end.join.html_safe
  end

  def sidebar(&block)
    content_for :sidebar do
      content_tag :div, class: 'sidebar' do
        content_tag :div, class: 'list-group' do
          capture(&block)
        end
      end
    end
  end

  def sidebar_header(text)
    content_tag :h4, text, class: 'sidebar-header'
  end

  def sidebar_item(opts = {}, &block)
    if perms = opts.delete(:perms)
      return nil if cannot?(*perms)
    end

    opts[:class] = '' if opts[:class].blank?
    opts[:class] += ' list-group-item'
    opts[:class] += ' active' if opts.delete(:active)

    content = if block_given?
      capture(&block)
    else
      desc = ActiveSupport::SafeBuffer.new
      if icon = opts.delete(:icon)
        desc << icon(icon) << ' '
      end
      desc << opts.delete(:text).to_s
      link_to(desc.html_safe, opts.delete(:path), opts)
    end

    content
  end

  private

  def nav_item(item)
    active = item[:active?] ? instance_eval(&item[:active?]) : (item[:controller] ? params[:controller] == item[:controller] : false)
    css = active ? 'active' : nil
    content_tag :li, link_to(element_value(item[:text]), element_value(item[:href])), class: css
  end

  def nav_item_authorized?(item)
    !item.has_key?(:authorized?) || instance_eval(&item[:authorized?])
  end

  def element_value(e)
    e.is_a?(Proc) ? instance_eval(&e) : e
  end
end
