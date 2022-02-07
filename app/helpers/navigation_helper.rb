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
      if nav_item_authorized?(item)
        if item[:items]
          content_tag :li, class: 'nav-item dropdown' do
            raw(nav_link(item, has_children: true) +
                content_tag(:div,
                    item[:items].select { |i| nav_item_authorized?(i) }
                                .map { |i| nav_link(i, class: 'dropdown-item') }.join.html_safe,
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
    content_tag :h3, text, class: 'sidebar-header'
  end

  def sidebar_item(opts = {}, &block)
    if perms = opts.delete(:perms)
      return nil if cannot?(*perms)
    end

    opts[:class] = '' if opts[:class].blank?
    opts[:class] += ' list-group-item list-group-item-action'
    opts[:class] += ' active' if opts.delete(:active)

    content = if block_given?
      capture(&block)
    else
      desc = ActiveSupport::SafeBuffer.new
      if icon = opts.delete(:icon)
        desc << icon(icon, 'fa-fw') << ' '
      end
      desc << opts.delete(:text).to_s
      link_to(desc.html_safe, opts.delete(:path), opts)
    end

    content
  end

  private

  def nav_item(item)
    active = item[:active?] ? instance_eval(&item[:active?]) : (item[:controller] ? params[:controller] == item[:controller] : false)
    css = 'nav-item'
    css << ' active' if active
    content_tag :li, class: css do
      nav_link(item)
    end
  end

  def nav_link(item, opts = {})
    active = item[:active?] ? instance_eval(&item[:active?]) : (item[:controller] ? params[:controller] == item[:controller] : false)

    css = opts[:class] || 'nav-link'
    css << ' dropdown-toggle' if opts[:has_children]
    css << ' active' if active

    link_opts = {
      class: css
    }

    dropdown_opts = {
      role: 'button',
      'aria-haspopup': true,
      'aria-expanded': false,
      data: { toggle: 'dropdown' }
    }
    link_opts.merge!(dropdown_opts) if opts[:has_children]

    link_to(element_value(item[:text]), element_value(item[:href]), link_opts)
  end

  def nav_item_authorized?(item)
    !item.has_key?(:authorized?) || instance_eval(&item[:authorized?])
  end

  def element_value(e)
    e.is_a?(Proc) ? instance_eval(&e) : e
  end
end
