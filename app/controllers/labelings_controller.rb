class LabelingsController < ApplicationController

  def create
    @owner_concept = Iqvoc::Concept.base_class.new_version(params[:versioned_concept_id]).first.blank? ? Iqvoc::Concept.base_class.initial_version(params[:versioned_concept_id]).first : Iqvoc::Concept.base_class.new_version(params[:versioned_concept_id]).first
    @target_label = Iqvoc::Label.base_class.find(params[:id])
    @versioned_target_label = Iqvoc::Label.base_class.new_version(@target_label.origin).first
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