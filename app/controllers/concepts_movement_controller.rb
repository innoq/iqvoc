# encoding: UTF-8

# Copyright 2011-2015 innoQ Deutschland GmbH
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

class ConceptsMovementController < ApplicationController
  include DatasetInitialization

  def move
    moved_concept = Iqvoc::Concept.base_class.find(params.require(:moved_node_id))

    if moved_concept.published?
      authorize! :branch, moved_concept
    else
      authorize! :update, moved_concept
    end

    ActiveRecord::Base.transaction do
      moved_concept_version = concept_version(moved_concept)

      if moved_concept_version.top_term?
        # we move a top term deeper into the tree
        moved_concept_version.update_attribute(:top_term, false)
        new_parent_concept = Iqvoc::Concept.base_class.find(params.require(:new_parent_node_id))
        create_new_relations(moved_concept_version, new_parent_concept)
      elsif params['new_parent_node_id'].nil?
        # we move a tree node to the top
        moved_concept_version.update_attribute(:top_term, true)
        old_parent_concept = Iqvoc::Concept.base_class.find(params.require(:old_parent_node_id))
        destroy_relations(old_parent_concept, moved_concept_version)
      else
        # regular inner tree node movement
        if params[:tree_action] == 'move' && Iqvoc::Concept.root_class.instance.mono_hierarchy?
          old_parent_concept = Iqvoc::Concept.base_class.find(params.require(:old_parent_node_id))

          destroy_relations(old_parent_concept, moved_concept_version)
        end

        new_parent_concept = Iqvoc::Concept.base_class.find(params.require(:new_parent_node_id))
        # add new relations to concept version
        create_new_relations(moved_concept_version, new_parent_concept)
      end
    end

    render nothing: true
  end

  protected

  def concept_params
    params.require(:concept).permit!
  end

  # get concept to work with
  # return a new version of the concept or the current draft (if exists)
  def concept_version(concept)
    if concept.published?
      # create a new version
      version = concept.branch(current_user)
      version.save!
    else
      # use current draft concept
      version = concept
    end

    version
  end

  def create_new_relations(moved_concept, new_parent)
    Iqvoc::Concept.broader_relation_class.create! do |r|
      r.owner = moved_concept
      r.target = new_parent
    end

    Concept::Relation::SKOS::Narrower::Base.create! do |r|
      r.owner = new_parent
      r.target = moved_concept
    end
  end

  def destroy_relations(owner, target)
    relation = owner.narrower_relations.find_by(target_id: target.id)
    relation.destroy! if relation

    relation = target.broader_relations.find_by(target_id: owner.id)
    relation.destroy! if relation
  end

end

