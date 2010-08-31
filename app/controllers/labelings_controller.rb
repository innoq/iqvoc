class LabelingsController < ApplicationController

  def create
    @owner_concept = Concept.new_version(params[:versioned_concept_id]).first.blank? ? Concept.initial_version(params[:versioned_concept_id]).first : Concept.new_version(params[:versioned_concept_id]).first
    @target_label = Label.find(params[:id])
    @versioned_target_label = Label.new_version(@target_label.origin).first
  end

  def destroy
    labeling = Labeling.find(params[:id])
    versioned_target_label = Label.new_version(labeling.target.origin).first
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