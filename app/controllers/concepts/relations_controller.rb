class Concepts::RelationsController < ApplicationController

  def create
    concept = load_concept
    relation_class = load_relation_class

    target_concepts = Concept::Base.by_origin(params[:origin]) # We'll have to point to unpublished new versions too
    raise ActiveRecord::RecordNotFound unless target_concepts.count > 0

    ActiveRecord::Base.transaction do
      target_concepts.each do |target_concept|
        concept.send(relation_class.name.to_relation_name).push_with_reflection_creation(relation_class.new(:target_id => target_concept.id))
      end
    end
    
    @relation = concept.send(relation_class.name.to_relation_name).editor_selectable.last
    render :json => { :origin => @relation.target.origin, :published => @relation.target.published?}.to_json
  end

  def destroy
    concept = load_concept
    relation_class = load_relation_class

    relations = concept.send(relation_class.name.to_relation_name).by_target_origin(params[:origin])
    raise ActiveRecord::RecordNotFound unless relations.count > 0

    ActiveRecord::Base.transaction do
      relations.each do |relation|
        concept.send(relation_class.name.to_relation_name).destroy_reflection(relation)
      end
    end

    head :ok
  end

  protected

  def load_concept
    concept = Iqvoc::Concept.base_class.by_origin(params[:versioned_concept_id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless concept
    concept
  end

  def load_relation_class
    raise "'#{params[:labeling_class]}' is not a valid / configured relation class!" unless Iqvoc::Concept.relation_class_names.include?(params[:relation_class])
    params[:relation_class].constantize
  end

end
