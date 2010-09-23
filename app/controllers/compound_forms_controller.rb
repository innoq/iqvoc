class CompoundFormsController < ApplicationController
  def create
    label = Iqvoc::XLLabel.base_class.find(params[:versioned_label_id])
    compound_form = label.compound_forms << UMT::CompoundForm.new
    render :json => { :id => compound_form.last.id}.to_json
    rescue
      head :internal_server_error
  end

  def destroy
    compound_form = UMT::CompoundForm.find(params[:id])
    if compound_form.destroy
      head :ok
    else
      head :internal_server_error
    end
  end
end