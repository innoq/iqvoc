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

  GLYPHS = {
    :yes => "&#x2713;",
    :no  => "&#x2717;"
  }

  def iqvoc_default_rdf_namespaces
    Iqvoc.rdf_namespaces.merge({
      :default => root_url(:format => nil, :lang => nil, :trailing_slash => true).gsub(/\/\/$/, "/"), # gsub because of a Rails bug :-(
      :coll => rdf_collections_url(:trailing_slash => true, :lang => nil, :format => nil),
      :schema => controller.schema_url(:format => nil, :anchor => "", :lang => nil)
    })
  end

  def user_details(user)
    details = mail_to(user.email, user.name)
    if user.telephone_number?
      details << " " << user.telephone_number
    end
    details
  end

  # Formats a list ob items or returns a remark if no items where given
  def item_listing(items, &block)
    return nil if items.empty?

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
      content_tag :div, :class => 'alert alert-error' do
        content_tag(:p, content_tag(:strong, t('txt.common.form_errors'))) <<
        content_tag(:ul) do
          object.errors.full_messages.each do |msg|
            concat content_tag(:li, msg)
          end
        end
      end
    end
  end

  def page_header(args = {})
    content_for :page_header do
      content_tag :div, :class => "page-header" do
        content_tag :h1 do
          ("#{args.delete(:title)} #{content_tag(:small, args.delete(:desc))}").html_safe
        end
      end
    end
  end

  def login_logout
    if current_user
      link_to t("txt.views.navigation.logout"), user_session_path, :method => :delete
    else
      link_to t("txt.views.navigation.login"), new_user_session_path
    end
  end

  def alert(type, opts = {}, &block)
    header = opts.delete(:header)

    html = ActiveSupport::SafeBuffer.new
    html << content_tag(:strong, header) if header
    html << capture(&block)

    content_tag(:div, :class => "alert alert-#{type}") do
      html
    end
  end

  def icon(name, white = nil)
    css_class = "icon-#{name}"
    css_class << " icon-white" if white

    content_tag :i, "", :class => css_class
  end

  def glyph(name)
    raw GLYPHS[name]
  end

  def html_classes(*args)
    args.compact.join(" ")
  end

end
