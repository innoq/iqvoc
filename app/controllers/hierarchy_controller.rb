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

class HierarchyController < ApplicationController

  def show
    authorize! :read, Iqvoc::Concept.base_class

    root_origin = params[:root]
    direction = params[:dir] == "up" ? "up" : "down"
    depth = params[:depth].blank? ? 3 : (Float(params[:depth]).to_i rescue nil)
    include_siblings = params[:siblings] || false
    include_unpublished = params[:published] == "0" # FIXME: requires additional AuthZ check

    scope = Iqvoc::Concept.base_class
    scope = include_unpublished ? scope.editor_selectable : scope.published

    # validate depth parameter
    error = "invalid depth parameter" unless depth # TODO: i18n
    # validate root parameter
    error = "missing root parameter" unless root_origin # TODO: i18n
    unless error
      root_concept = scope.where(:origin => root_origin).first
      error = [404, "no concept matching root parameter"] unless root_concept # TODO: i18n
    end
    # error handling
    if error
      status, error = error if error.is_a? Array
      flash.now[:error] = error
      render :status => (status || 400)
      return
    end

    # caching -- NB: invalidated on any in-scope concept modifications
    latest = scope.maximum(:updated_at)
    response.cache_control[:public] = !include_unpublished # XXX: this should not be necessary!?
    return unless stale?(:etag => [latest, params], :last_modified => latest,
        :public => !include_unpublished)

    # NB: order matters due to the `where` clause below
    if direction == "up"
      scope = scope.includes(:narrower_relations, :broader_relations)
    else
      scope = scope.includes(:broader_relations, :narrower_relations)
    end

    @concepts = {}
    if include_siblings
      determine_siblings(root_concept).each { |sib| @concepts[sib] = {} }
    end
    @concepts[root_concept] = populate_hierarchy(root_concept, scope, depth, 0,
        include_siblings)

    @relation_class = Iqvoc::Concept.broader_relation_class
    @relation_class = @relation_class.narrower_class unless direction == "up"

    respond_to do |format|
      format.html
      format.ttl
      format.rdf
    end
  end

  private

  # returns a hash of concept/relations pairs of arbitrary nesting depth
  # NB: recursive, triggering one database query per iteration
  def populate_hierarchy(root_concept, scope, max_depth, current_depth=0,
      include_siblings=false)
    current_depth += 1
    return {} if current_depth > max_depth

    rels = scope.where(Concept::Relation::Base.arel_table[:target_id].
        eq(root_concept.id))
    return rels.inject({}) do |memo, concept|
      if include_siblings
        determine_siblings(concept).each { |sib| memo[sib] = {} }
      end
      memo[concept] = populate_hierarchy(concept, scope, max_depth,
          current_depth, include_siblings)
      memo
    end
  end

  # NB: includes support for poly-hierarchies -- XXX: untested
  def determine_siblings(concept)
    return concept.broader_relations.map do |rel|
      rel.target.narrower_relations.map { |rel| rel.target } # XXX: expensive
    end.flatten.uniq
  end

end
