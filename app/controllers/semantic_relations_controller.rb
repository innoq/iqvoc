class SemanticRelationsController < ApplicationController
  def create
    @owner_concept = Iqvoc::Concept.base_class.new_version(params[:versioned_concept_id]).first.blank? ? Iqvoc::Concept.base_class.initial_version(params[:versioned_concept_id]).first : Iqvoc::Concept.base_class.new_version(params[:versioned_concept_id]).first
    @target_concept = Iqvoc::Concept.base_class.find(params[:id])
  end
end
