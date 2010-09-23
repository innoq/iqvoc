class CompoundFormContentsController < ApplicationController
  def create
    compound_form = UMT::CompoundForm.find(params[:compound_form_id])
    label = Iqvoc::XLLabel.base_class.find(params[:id])
    label_new_version = Iqvoc::XLLabel.base_class.new_version(label.origin).first
    if label_new_version.present?
      compound_form.compound_form_contents << UMT::CompoundFormContent.new(:label_id => label_new_version.id)
    end
    compound_form_content = compound_form.compound_form_contents << UMT::CompoundFormContent.new(:label_id => label.id)
    render :json => { :id => compound_form_content.last.id}.to_json
    rescue
      head :internal_server_error
  end

  def destroy
    compound_form_content = UMT::CompoundFormContent.find(params[:id])
    versioned_label = Iqvoc::XLLabel.base_class.new_version(compound_form_content.label.origin).first
    if versioned_label.present?
      versioned_label_compound_form_content = UMT::CompoundFormContent.find(:first, :conditions => ["compound_form_id = :compound_form_id AND label_id = :label_id", {:compound_form_id => compound_form_content.compound_form_id, :label_id => versioned_label.id}])
      ActiveRecord::Base.transaction do
      if compound_form_content.destroy && versioned_label_compound_form_content.destroy
        head :ok
      else
        head :internal_server_error
      end
      end
    else
      if compound_form_content.destroy
        head :ok
      else
        head :internal_server_error
      end
    end
    rescue
    head :internal_server_error
  end
end