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

class Concepts::HierarchicalController < ConceptsController
  def index
    base_class = Iqvoc::Concept.base_class

    if params[:published] == '0'
      authorize! :update, base_class
    else
      authorize! :read, base_class
    end

    scope = base_class.includes(base_class.default_includes + [:pref_labels]).order('labels.value')
    scope = params[:published] == '0' ? scope.published_with_newer_versions : scope.published

    # only select unexpired concepts
    scope = scope.not_expired

    # unrelated concepts for sidebar
    # TODO: order parentless concepts
    @loose_concepts = scope.parentless.includes(:pref_labels).page(params[:page])

    # if params[:broader] is given, the action is handling the reversed tree
    root_id = params[:root]
    if root_id && root_id =~ /\d+/
      # NB: order matters; see the following `where`
      if params[:broader]
        scope = scope.includes(:narrower_relations, :broader_relations).references(:relations)
      else
        scope = scope.includes(:broader_relations, :narrower_relations).references(:relations)
      end
      @concepts = scope.where(Concept::Relation::Base.arel_table[:target_id].eq(root_id))
    else
      if params[:broader]
        @concepts = scope.broader_tops.includes(:broader_relations).references(:concepts)
      else
        @concepts = scope.tops.includes(:narrower_relations).references(:concepts)
      end
    end

    respond_to do |format|
      format.html
      format.json do # Treeview data
        concepts = @concepts.select { |c| can? :read, c }.map do |c|
          url = (c.published?) ? concept_path(id: c, format: :html) : concept_path(id: c, format: :html, published: 0)

          load_on_demand = if params[:published] == '0'
                             params[:broader] ? c.broader_relations.any? : c.narrower_relations.any?
                           else
                             params[:broader] ? c.broader_relations.published.any? : c.narrower_relations.published.any?
                           end

          {
            id: c.id,
            label: CGI.escapeHTML(c.pref_label.to_s),
            additionalText: (" (#{c.additional_info})" if c.additional_info.present?),
            load_on_demand: load_on_demand,
            url: url,
            update_url: move_concept_url(c),
            glance_url: glance_concept_url(c, format: :html),
            published: (c.published?) ? true : false
          }
        end
        render json: concepts
      end
    end
  end
end
