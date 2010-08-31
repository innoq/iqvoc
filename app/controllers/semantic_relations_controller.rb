class SemanticRelationsController < ApplicationController
  def create
    @owner_concept = Concept.new_version(params[:versioned_concept_id]).first.blank? ? Concept.initial_version(params[:versioned_concept_id]).first : Concept.new_version(params[:versioned_concept_id]).first
    @target_concept = Concept.find(params[:id])
  end
end
