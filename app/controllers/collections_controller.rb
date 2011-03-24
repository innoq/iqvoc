class CollectionsController < ApplicationController
  @@klass = Iqvoc::Collection.class_name.constantize

  skip_before_filter :require_user

  def index
    authorize! :read, @@klass

    respond_to do |format|
      format.html do
        @collections = @@klass.all.sort{ |a, b| a.label.to_s <=> b.label.to_s }
      end
      format.json do
        @collections = (@@klass.with_pref_labels & Label::Base.by_query_value("#{params[:query]}%")).all
        response = []
        @collections.each { |c| response << collection_widget_data(c) }
        render :json => response
      end
    end
  end

  def show
    @collection = @@klass.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :read, @collection
  end

  def new
    authorize! :create, @@klass

    @collection = @@klass.new
    build_note_relations
  end

  def create
    authorize! :create, @@klass

    @collection = @@klass.new(params[:concept])

    if @collection.save
      flash[:notice] = I18n.t("txt.controllers.collections.save.success")
      redirect_to collection_path(@collection, :lang => I18n.locale)
    else
      flash.now[:error] = I18n.t("txt.controllers.collections.save.error")
      render :new
    end
  end

  def edit
    @collection = @@klass.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :update, @collection
    build_note_relations
  end

  def update
    @collection = @@klass.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :update, @collection

    if @collection.update_attributes(params[:concept])
      flash[:notice] = I18n.t("txt.controllers.collections.save.success")
      redirect_to collection_path(@collection, :lang => I18n.locale)
    else
      flash.now[:error] = I18n.t("txt.controllers.collections.save.error")
      render :edit
    end
  end

  def destroy
    @collection = @@klass.by_origin(params[:id]).last
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
    @collection.note_skos_definitions.build if @collection.note_skos_definitions.empty?
  end

end
