class Concepts::RelationsController < ApplicationController

  def create
    concept = load_concept
    
    authorize! :update, concept
    
    relation_class = load_relation_class

    target_concept = Concept::Base.by_origin(params[:origin]).editor_selectable.last
    raise ActiveRecord::RecordNotFound unless target_concept
    target_concepts_new_version = Concept::Base.by_origin(params[:origin]).unpublished.last

    ActiveRecord::Base.transaction do
      concept.send(relation_class.name.to_relation_name).create_with_reverse_relation(relation_class, target_concept)
      if target_concepts_new_version and target_concepts_new_version.rev > target_concept.rev
        concept.send(relation_class.name.to_relation_name).create_with_reverse_relation(relation_class, target_concepts_new_version)
      end
    end
    
    render :json => { :origin => target_concept.origin, :published => target_concept.published?}.to_json
  end

  def destroy
    concept = load_concept
    
    authorize! :update, concept
    
    relation_class = load_relation_class

    target_concepts = [Concept::Base.by_origin(params[:origin]).editor_selectable.last].compact
    raise ActiveRecord::RecordNotFound unless target_concepts.count > 0
    target_concepts_new_version = Concept::Base.by_origin(params[:origin]).unpublished.last
    target_concepts << target_concepts_new_version if target_concepts_new_version and target_concepts_new_version.rev > target_concepts.first.rev

    ActiveRecord::Base.transaction do
      target_concepts.each do |target_concept|
        concept.send(relation_class.name.to_relation_name).destroy_with_reverse_relation(relation_class, target_concept)
      end
    end

    head :ok
  end

  protected

  def load_concept
    concept = Iqvoc::Concept.base_class.by_origin(params[:concept_id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless concept
    concept
  end

  def load_relation_class
    raise "'#{params[:labeling_class]}' is not a valid / configured relation class!" unless Iqvoc::Concept.relation_class_names.include?(params[:relation_class])
    params[:relation_class].constantize
  end

end
