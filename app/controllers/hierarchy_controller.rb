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

class HierarchyController < ApplicationController # XXX: largely duplicates concepts' hierarchical controller

  def show
    authorize! :read, Iqvoc::Concept.base_class

    root_origin = params[:root]
    direction = params[:dir] == "up" ? "up" : "down"
    depth = (params[:depth] || "3").to_i
    siblings = params[:siblings] || false

    scope = Iqvoc::Concept.base_class
    scope = params[:published] == "0" ? scope.editor_selectable : scope.published

    error = "missing root parameter" unless root_origin # TODO: i18n
    unless error
      root_concept = scope.where(:origin => root_origin).first
      error = "invalid root parameter" unless root_concept # TODO: i18n
    end
    if error
      flash.now[:error] = error
      render :status => 400
      return
    end

    # NB: order matters due to the `where` clause below
    if direction == "up"
      scope = scope.includes(:narrower_relations, :broader_relations)
    else
      scope = scope.includes(:broader_relations, :narrower_relations)
    end

    @concepts = {}
    @concepts[root_concept] = populate_hierarchy(root_concept, scope, depth)
  end

  # returns a hash of concept/relations pairs of arbitrary nesting depth
  # NB: recursive, triggering one database query per iteration
  def populate_hierarchy(root_concept, scope, max_depth, current_depth=0)
    current_depth += 1
    data = {}

    return data if current_depth > max_depth

    rels = scope.where(Concept::Relation::Base.arel_table[:target_id].
        eq(root_concept.id))
    rels.each do |concept|
      data[concept] = populate_hierarchy(concept, scope, max_depth, current_depth)
    end

    return data
  end

end
