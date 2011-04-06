class RdfController < ApplicationController

  skip_before_filter :require_user

  def show
    scope = params[:published] == "0" ? Iqvoc::Concept.base_class.scoped.unpublished : Iqvoc::Concept.base_class.scoped.published
    if @concept = scope.by_origin(params[:id]).with_associations.last
      respond_to do |format|
        format.html {
          redirect_to concept_url(:id => @concept.origin, :lang => I18n.locale, :published => params[:published])
        }
        format.any {
          authorize! :read, @concept
          render "show_concept"
        }
      end
    else
      raise ActiveRecord::RecordNotFound.new("Coulnd't find either a concept matching '#{params[:id]}'.")
    end
  end

end