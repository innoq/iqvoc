class LabelingsController < ApplicationController

  def create
    concept = Iqvoc::Concept.base_class.by_origin(params[:versioned_concept_id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless concept

    raise "'#{params[:labeling_class]}' is not a valid / configured labeling class!" unless Iqvoc::Concept.labeling_class_names.keys.include?(params[:labeling_class])
    labeling_class = params[:labeling_class].constantize

    labels = Label::SKOSXL::Base.by_origin(params[:origin]) # We'll have to point to unpublished new versions of labels too
    raise ActiveRecord::RecordNotFound unless labels.count > 0

    labels.each do |label|
      concept.send(labeling_class.name.to_relation_name) << labeling_class.new(:target_id => label.id)
    end
    @labeling = concept.send(labeling_class.name.to_relation_name).by_label_origin(params[:origin]).label_editor_selectable.last
    render :json => { :id => @labeling.id, :origin => @labeling.target.origin, :published => @labeling.target.published?}.to_json
  end

  def destroy
    labeling = Labeling.find(params[:id])
    versioned_target_label = Iqvoc::Label.base_class.new_version(labeling.target.origin).first
    if versioned_target_label.present?
      versioned_target_labeling = labeling.class.name.constantize.find(:first, :conditions => ["owner_id = :owner_id AND target_id = :target_id", {:owner_id => labeling.owner_id, :target_id => versioned_target_label.id}])
      ActiveRecord::Base.transaction do
        if labeling.destroy && versioned_target_labeling.destroy
          head :ok
        else
          head :internal_server_error
        end
      end
    else
      if labeling.destroy
        head :ok
      else
        head :internal_server_error
      end
    end
  rescue
    head :internal_server_error
  end
end