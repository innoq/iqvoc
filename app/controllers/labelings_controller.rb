class LabelingsController < ApplicationController

  def create
    concept = Iqvoc::Concept.base_class.by_origin(params[:versioned_concept_id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless concept

    raise "'#{params[:labeling_class]}' is not a valid / configured labeling class!" unless Iqvoc::Concept.labeling_class_names.keys.include?(params[:labeling_class])
    labeling_class = params[:labeling_class].constantize

    labels = Label::SKOSXL::Base.by_origin(params[:origin]) # We'll have to point to unpublished new versions of labels too
    raise ActiveRecord::RecordNotFound unless labels.count > 0

    ActiveRecord::Base.transaction do
      labels.each do |label|
        concept.send(labeling_class.name.to_relation_name) << labeling_class.new(:target_id => label.id)
      end
    end

    @labeling = concept.send(labeling_class.name.to_relation_name).by_label_origin(params[:origin]).label_editor_selectable.last

    render :json => { :id => @labeling.id, :origin => @labeling.target.origin, :published => @labeling.target.published?}.to_json
  end

  def destroy
    concept = Iqvoc::Concept.base_class.by_origin(params[:versioned_concept_id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless concept

    raise "'#{params[:labeling_class]}' is not a valid / configured labeling class!" unless Iqvoc::Concept.labeling_class_names.keys.include?(params[:labeling_class])
    labeling_class = params[:labeling_class].constantize

    labelings = concept.send(labeling_class.name.to_relation_name).by_label_origin(params[:origin])

    ActiveRecord::Base.transaction do
      labelings.each do |labeling|
        labeling.destroy
      end
    end
    head :ok
  end
end