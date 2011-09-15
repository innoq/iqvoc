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

class Concepts::HierarchicalController < ConceptsController
  skip_before_filter :require_user

  def index
    authorize! :read, Iqvoc::Concept.base_class

    scope = if params[:published] == '0'
      Iqvoc::Concept.base_class.editor_selectable
    else
      Iqvoc::Concept.base_class.published
    end

    # if params[:broader] is given, the action is handling the reversed tree
    @concepts = case params[:root]
    when /\d+/
      root_concept = Iqvoc::Concept.base_class.find(params[:root])
      if params[:broader]
        scope.
          includes(:narrower_relations, :broader_relations). # D A N G E R: the order matters!!! See the following where
        where(Concept::Relation::Base.arel_table[:target_id].eq(root_concept.id))
      else
        scope.
          includes(:broader_relations, :narrower_relations). # D A N G E R: the order matters!!! See the following where
        where(Concept::Relation::Base.arel_table[:target_id].eq(root_concept.id))
      end
    else
      if params[:broader]
        scope.broader_tops.includes(:broader_relations)
      else
        scope.tops.includes(:narrower_relations)
      end
    end
    # When in single query mode, AR handles ALL includes to be loaded by that
    # one query. We don't want that! So let's do it manually :-)
    ActiveRecord::Associations::Preloader.new(@concepts, Iqvoc::Concept.base_class.default_includes + [:pref_labels]).run

    @concepts.sort! do |a, b|
      a.pref_label.to_s <=> b.pref_label.to_s
    end

    respond_to do |format|
      format.html
      format.json do # Treeview data
        @concepts.map! do |c|
          {
            :id   => c.id,
            :url  => concept_path(:id => c, :format => :html),
            :text => CGI.escapeHTML(c.pref_label.to_s),
            :hasChildren => (params[:broader] ? c.broader_relations.any? : c.narrower_relations.any?),
            :additionalText => (" (#{c.additional_info})" if c.additional_info.present?)
          }
        end
        render :json => @concepts.to_json
      end
    end
  end

end
