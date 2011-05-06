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

class Collections::HierarchicalController < CollectionsController
  skip_before_filter :require_user # XXX: why? (cf. concepts/hierarchical)

  def index
    authorize! :read, Collection::Base

    root = Iqvoc::Collection.base_class.find(params[:root])
    children = root.subcollections

    children.sort! do |a, b|
      a.pref_label.to_s <=> b.pref_label.to_s
    end

    respond_to do |format|
      format.json do
        children.map! do |collection|
          {
            :id => collection.id,
            :url => collection_path(:lang => I18n.locale, :id => collection),
            :text => CGI.escapeHTML(collection.pref_label.to_s),
            :hasChildren => collection.subcollections.any?
          }
        end
        render :json => children.to_json
      end
    end
  end

end
