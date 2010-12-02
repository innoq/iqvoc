class CollectionsController < ApplicationController

  def index
    @collections = Collection::SKOS::Base.all
  end
  
  def show
    @collection = Collection::SKOS::Base.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :read, @collection
  end
  
  def new
    authorize! :create, Collection::SKOS::Base

    @collection = Collection::SKOS::Unordered.new
    build_note_relations
  end
  
  def create
    authorize! :create, Collection::SKOS::Base

    @collection = Collection::SKOS::Unordered.new(params[:collection])
    
    if @collection.save
      flash[:notice] = I18n.t("txt.controllers.collections.save.success")
      redirect_to collection_path(@collection, :lang => I18n.locale)
    else
      flash[:error] = I18n.t("txt.controllers.collections.save.error")
      render :new
    end
  end
  
  def edit
    @collection = Collection::SKOS::Base.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :update, @collection
    build_note_relations
  end
  
  def update
    @collection = Collection::SKOS::Base.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :update, @collection
    
    if @collection.update_attributes(params[:collection])
      flash[:notice] = I18n.t("txt.controllers.collections.save.success")
      redirect_to collection_path(@collection, :lang => I18n.locale)
    else
      flash[:error] = I18n.t("txt.controllers.collections.save.error")
      render :edit
    end
  end
  
  def destroy
    @collection = Collection::SKOS::Base.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :destroy, @collection

    if @collection.destroy
      flash[:notice] = I18n.t("txt.controllers.collections.destroy.success")
      redirect_to collections_path(:lang => I18n.locale)
    else
      flash[:error] = I18n.t("txt.controllers.collections.destroy.error")
      render :action => :show
    end
  end
  
  private
  
  def build_note_relations
    @collection.note_iqvoc_language_notes.build if @collection.note_iqvoc_language_notes.empty?
    @collection.note_skos_definitions.build if @collection.note_skos_definitions.empty?
  end
  
end
