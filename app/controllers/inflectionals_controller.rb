class InflectionalsController < ApplicationController
  
  def index
    @inflectionals = Inflectional.search(params[:query])
    respond_to do |format|
      format.json { render :text => @inflectionals.to_json(:include => :label) }
    end
  end
  
end