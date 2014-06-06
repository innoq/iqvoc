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

module SearchResultsHelper
  def search_language_selected?(lang)
    (params[:languages] && params[:languages].include?(lang.to_s)) ||
      (!params[:query] && I18n.locale.to_s == lang.to_s)
  end

  def search_dataset_selected?(adaptor)
    params[:datasets] && params[:datasets].include?(adaptor.to_s)
  end

  def highlight_query(text, query)
    query.split(/\n/).each do |q|
      # call to ActiveSupport's highlight
      text = highlight(text.to_s, q.strip)
    end
    text
  end

  def results_header(results)
    desc = if results.any?
      "(#{results.total_count})"
    else
      t('txt.views.search_results.no_results_found')
    end

    content_tag :h2 do
      raw( t('txt.views.search_results.search_results') << ' ' << content_tag(:small, desc) )
    end
  end
end
