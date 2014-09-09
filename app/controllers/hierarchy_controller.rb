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
  resource_description do
    name 'Hierarchy'
  end

  api :GET, 'hierarchy', 'Retrieve the downwards concepts hierarchy starting '\
                         'at top concepts.'
  formats [:html, :ttl, :rdf]
  example <<-DOC
    GET /hierarchy.ttl
    200

    # omitted namespace definitions
    :achievement_hobbies a skos:Concept;
                         skos:topConceptOf :scheme;
                         skos:prefLabel "Achievement hobbies"@en;
                         skos:narrower :model_building;
                         skos:narrower :gardening.
    :model_building a skos:Concept;
                    skos:prefLabel "Model building"@en;
                    skos:narrower :model_rocketry;
    :model_rocketry a skos:Concept;
                    skos:prefLabel "Model rocketry"@en.
    :gardening a skos:Concept;
               skos:prefLabel "Gardening"@en.
  DOC

  def index
    authorize! :read, Iqvoc::Concept.base_class

    # special-casing to avoid confusion, based on user feedback
    if params[:root]
      msg = ['to use a specific concept as hierarchy root, please use',
          url_for(params.merge 'action' => 'show')].join("\n")
      render status: 400, text: msg
      return
    end

    depth = params[:depth] || (unbounded? ? -1 : nil)

    render_hierarchy 'scheme', depth, unbounded?
  end

  api :GET, 'hierarchy/:root', "Retrieve a concept's up- or downwards "\
                               'hierarchy with optional siblings.'
  formats [:html, :ttl, :rdf]
  param :dir, ['down', 'up'],
      desc: <<-DOC
      Direction of the hierarchy.

      *down* follow narrower from root to its leaf nodes.

      *up* follow broader from root to its top term(s).
      DOC
  param :depth, [1, 2, 3, 4],
      'Number of levels of hierarchy to be included in the response'
  param :siblings, ['1', 'true'],
      'Siblings of each node will be included even if they are not part of '\
      'the hierarchy.'
  example <<-DOC
    GET /hierarchy/model_building.ttl?dir=down&depth=1

    # omitted namespace definitions
    :model_rocketry a skos:Concept;
                    skos:prefLabel "Model rocketry"@en.
    :radio-controlled_modeling a skos:Concept;
                               skos:prefLabel "Radio-controlled modeling"@en.
    :scale_modeling a skos:Concept;
                    skos:prefLabel "Scale modeling"@en.
    :model_building a skos:Concept;
                    skos:prefLabel "Model building"@en;
                    skos:narrower :model_rocketry;
                    skos:narrower :radio-controlled_modeling;
                    skos:narrower :scale_modeling.
  DOC

  def show
    authorize! :read, Iqvoc::Concept.base_class

    render_hierarchy params[:root], params[:depth], unbounded?
  end

  private

  def unbounded?
    Iqvoc.config['performance.unbounded_hierarchy']
  end

  def render_hierarchy(root_origin, depth, unbounded = false)
    default_depth = 3
    max_depth = 4 # XXX: arbitrary

    direction = params[:dir] == 'up' ? 'up' : 'down'
    depth = depth.blank? ? default_depth : (Float(depth).to_i rescue nil)
    include_siblings = ['true', '1'].include?(params[:siblings])
    include_unpublished = params[:published] == '0'

    scope = Iqvoc::Concept.base_class
    scope = include_unpublished ? scope.editor_selectable : scope.published

    # validate depth parameter
    if not depth
      error = 'invalid depth parameter' # TODO: i18n
    elsif depth > max_depth and not unbounded
      error = [403, 'excessive depth'] # TODO: i18n
    end
    # validate root parameter
    error = 'missing root parameter' unless root_origin # TODO: i18n
    unless error
      root_concepts = root_origin == 'scheme' ? scope.tops.load : # XXX: special-casing
          scope.where(origin: root_origin).load
      unless root_concepts.length > 0
        error = [404, 'no concept matching root parameter'] # TODO: i18n
      end
    end
    # error handling
    if error
      status, error = error if error.is_a? Array
      flash.now[:error] = error
      render 'hierarchy/show', status: (status || 400)
      return
    end

    # caching -- NB: invalidated on any in-scope concept modifications
    latest = scope.maximum(:updated_at)
    response.cache_control[:public] = !include_unpublished # XXX: this should not be necessary!?
    return unless stale?(etag: [latest, params], last_modified: latest,
        public: !include_unpublished)

    # NB: order matters due to the `where` clause below
    if direction == 'up'
      scope = scope.includes(:narrower_relations, :broader_relations)
    else
      scope = scope.includes(:broader_relations, :narrower_relations)
    end

    @concepts = {}
    root_concepts.each do |root_concept|
      if include_siblings
        determine_siblings(root_concept).each { |sib| @concepts[sib] = {} }
      end
      @concepts[root_concept] = populate_hierarchy(root_concept, scope, depth,
          0, include_siblings)
    end

    @relation_class = Iqvoc::Concept.broader_relation_class
    @relation_class = @relation_class.narrower_class unless direction == 'up'

    respond_to do |format|
      format.any(:html, :rdf, :ttl) { render 'hierarchy/show' }
    end
  end

  # returns a hash of concept/relations pairs of arbitrary nesting depth
  # NB: recursive, triggering one database query per iteration
  def populate_hierarchy(root_concept, scope, max_depth, current_depth = 0,
        include_siblings = false)
    current_depth += 1
    return {} if max_depth != -1 and current_depth > max_depth

    rels = scope.where(Concept::Relation::Base.arel_table[:target_id].
        eq(root_concept.id)).references(:concept_relations)
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
