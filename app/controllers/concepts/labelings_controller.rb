class Concepts::LabelingsController < ApplicationController

  def create
    concept = load_concept
    labeling_class = load_labeling_class

    label = labeling_class.label_class.by_origin(params[:origin]).editor_selectable.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find label with origin '#{params[:origin]}'.") unless label
    labels_new_version labeling_class.label_class.by_origin(params[:origin]).unpublished.last

    ActiveRecord::Base.transaction do
      concept.send(labeling_class.name.to_relation_name).find_or_create_by_target_id(label.id)
      concept.send(labeling_class.name.to_relation_name).find_or_create_by_target_id(labels_new_version.id) if labels_new_version and labels_new_version.rev > label.rev
    end
    
    render :json => { :origin => label.origin, :published => label.published?}.to_json
  end

  def destroy
    concept = load_concept
    labeling_class = load_labeling_class

    labelings = concept.send(labeling_class.name.to_relation_name).by_label_origin(params[:origin])

    ActiveRecord::Base.transaction do
      labelings.each do |labeling|
        labeling.destroy
      end
    end
    head :ok
  end

  protected

  def load_concept
    concept = Iqvoc::Concept.base_class.by_origin(params[:versioned_concept_id]).unpublished.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find concept with origin '#{params[:versioned_concept_id]}'.") unless concept
    concept
  end

  def load_labeling_class
    raise "'#{params[:labeling_class]}' is not a valid / configured labeling class!" unless Iqvoc::Concept.labeling_class_names.keys.include?(params[:labeling_class])
    params[:labeling_class].constantize
  end

end