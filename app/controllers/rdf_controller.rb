class RdfController < ApplicationController

  skip_before_filter :require_user
  skip_before_filter :ensure_extension
   
  def show
    respond_to do |format|
      format.html {
        if concept = Iqvoc::Concept.base_class.by_origin(params[:id]).published.last
          redirect_to concept_url(:id => concept.origin, :lang => I18n.locale)
        elsif label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).published.last
          redirect_to label_url(:id => label.origin, :lang => I18n.locale)
        else
          raise ActiveRecord::RecordNotFound.new("Coulnd't find either a concept or a label matching '#{params[:id]}'.")
        end
      }
      format.any {
        if @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).published.with_associations.last
          render "show_concept"
        elsif label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).published.last
          redirect_to label_url(:id => label.origin, :lang => I18n.locale)
        else
          raise ActiveRecord::RecordNotFound.new("Coulnd't find either a concept or a label matching '#{params[:id]}'.")
        end
      }
    end
  end
  
end