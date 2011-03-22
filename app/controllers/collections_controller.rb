class CollectionsController < ApplicationController

  skip_before_filter :require_user

  def index
    authorize! :read, Collection::Base

    respond_to do |format|
      format.html do
        @collections = Collection::Base.all.sort{ |a, b| a.label.to_s <=> b.label.to_s }
      end
      format.json do
        @collections = (Collection::Base.includes(:collection_labels) & CollectionLabel.by_query_value("#{params[:query]}%")).all
        response = []
        @collections.each { |c| response << collection_widget_data(c) }
        render :json => response
      end
    end
  end

  def show
    @collection = Collection::Base.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :read, @collection
  end

  def new
    authorize! :create, Collection::Base

    @collection = Collection::Unordered.new
    build_note_relations
  end

  def create
    authorize! :create, Collection::Base

    @collection = Collection::Unordered.new(params[:collection])

    if @collection.save
      flash[:notice] = I18n.t("txt.controllers.collections.save.success")
      redirect_to collection_path(@collection, :lang => I18n.locale)
    else
      flash.now[:error] = I18n.t("txt.controllers.collections.save.error")
      render :new
    end
  end

  def edit
    @collection = Collection::Base.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :update, @collection
    build_note_relations
  end

  def update
    @collection = Collection::Base.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :update, @collection

    if @collection.update_attributes(params[:collection])
      flash[:notice] = I18n.t("txt.controllers.collections.save.success")
      redirect_to collection_path(@collection, :lang => I18n.locale)
    else
      flash.now[:error] = I18n.t("txt.controllers.collections.save.error")
      render :edit
    end
  end

  def destroy
    @collection = Collection::Base.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :destroy, @collection

    if @collection.destroy
      flash[:notice] = I18n.t("txt.controllers.collections.destroy.success")
      redirect_to collections_path(:lang => I18n.locale)
    else
      flash.now[:error] = I18n.t("txt.controllers.collections.destroy.error")
      render :action => :show
    end
  end

  private

  def build_note_relations
    @collection.collection_labels.build if @collection.collection_labels.empty?
    @collection.note_skos_definitions.build if @collection.note_skos_definitions.empty?
  end

end
