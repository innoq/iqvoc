class CollectionsController < ApplicationController

  def index
    @collections = Collection::SKOS::Base.all
  end
  
  def show
    @collection = Collection::SKOS::Base.find(params[:id])
  end
  
  def new
    @collection = Collection::SKOS::Base.new
    @collection.note_iqvoc_language_notes.build if @collection.note_iqvoc_language_notes.empty?
    @collection.note_skos_definitions.build if @collection.note_skos_definitions.empty?
  end
  
  def create
    @collection = Collection::SKOS::Base.new(params[:collection])
    
    if @collection.save
      flash[:error] = I18n.t("txt.controllers.collections.save.success")
      redirect_to collections_path(:lang => I18n.locale)
    else
      flash[:error] = I18n.t("txt.controllers.collections.save.error")
      render :new
    end
  end
  
end
