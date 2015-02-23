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

    new_parent_concept = Iqvoc::Concept.base_class.find(params.require(:new_parent_node_id))
    new_parent_concept_version = concept_version(new_parent_concept)

    ActiveRecord::Base.transaction do
      moved_concept_version = concept_version(moved_concept)

      if params[:tree_action] == 'move' && Iqvoc::Concept.root_class.instance.mono_hierarchy?
        if moved_concept.top_term?
          moved_concept_version.update_attribute(:top_term, false)
        else
          # removed old relations
          old_parent_concept = Iqvoc::Concept.base_class.find(params.require(:old_parent_node_id))
          old_parent_concept_version = concept_version(old_parent_concept)

          moved_concept_version.send(Iqvoc::Concept.broader_relation_class_name.to_relation_name)
             .destroy_with_reverse_relation(old_parent_concept_version)

          # delete relations which will be created during branching
          if old_parent_concept_version.narrower_relations.find_by(target_id: moved_concept.id)
            old_parent_concept_version.narrower_relations.find_by(target_id: moved_concept.id).destroy!
          end
          if moved_concept_version.broader_relations.find_by(target_id: old_parent_concept.id)
            moved_concept_version.broader_relations.find_by(target_id: old_parent_concept.id).destroy!
          end
        end
      end

      # add new relations to concept version
      Iqvoc::Concept.broader_relation_class.create! do |r|
        r.owner = moved_concept_version
        r.target = new_parent_concept_version
      end

      Concept::Relation::SKOS::Narrower::Base.create! do |r|
        r.owner = new_parent_concept_version
        r.target = moved_concept_version
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

end

