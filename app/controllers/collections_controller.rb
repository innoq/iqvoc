# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class CollectionsController < ApplicationController
  skip_before_filter :require_user

  def index
    authorize! :read, Iqvoc::Collection.base_class

    respond_to do |format|
      format.html do
        @top_collections = Iqvoc::Collection.base_class.
          with_pref_labels.
          tops.
          sort { |a, b| a.pref_label.to_s <=> b.pref_label.to_s }

        # When in single query mode, AR handles ALL includes to be loaded by that
        # one query. We don't want that! So let's do it manually :-)
        ActiveRecord::Associations::Preloader.new(@collections, [:subcollections]).run
      end
      format.json do # For the widget
        @collections = Iqvoc::Collection.base_class.with_pref_labels.merge(Label::Base.by_query_value("#{params[:query]}%"))
        response = []
        @collections.each { |c| response << collection_widget_data(c) }
        render :json => response
      end
    end
  end

  def show
    @collection = Iqvoc::Collection.base_class.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :read, @collection

    # When in single query mode, AR handles ALL includes to be loaded by that
    # one query. We don't want that! So let's do it manually :-)
    ActiveRecord::Associations::Preloader.new(@collection, 
      [:pref_labels, 
      {:subcollections => [:pref_labels, :subcollections]},
      {:concepts => [:pref_labels] + Iqvoc::Concept.base_class.default_includes}]).run
  end

  def new
    authorize! :create, Iqvoc::Collection.base_class

    @collection = Iqvoc::Collection.base_class.new
    build_note_relations
  end

  def create
    authorize! :create, Iqvoc::Collection.base_class

    @collection = Iqvoc::Collection.base_class.new(params[:concept])

    if @collection.save
      flash[:notice] = I18n.t("txt.controllers.collections.save.success")
      redirect_to collection_path(:id => @collection)
    else
      flash.now[:error] = I18n.t("txt.controllers.collections.save.error")
      render :new
    end
  end

  def edit
    @collection = Iqvoc::Collection.base_class.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :update, @collection

    # When in single query mode, AR handles ALL includes to be loaded by that
    # one query. We don't want that! So let's do it manually :-)
    ActiveRecord::Associations::Preloader.new(@collection, [
      :pref_labels, 
      {:subcollections => :pref_labels}, 
      {:concepts => [:pref_labels] + Iqvoc::Concept.base_class.default_includes}]).run
      
    build_note_relations
  end

  def update
    @collection = Iqvoc::Collection.base_class.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :update, @collection

    if @collection.update_attributes(params[:concept])
      flash[:notice] = I18n.t("txt.controllers.collections.save.success")
      redirect_to collection_path(:id => @collection)
    else
      flash.now[:error] = I18n.t("txt.controllers.collections.save.error")
      render :edit
    end
  end

  def destroy
    @collection = Iqvoc::Collection.base_class.by_origin(params[:id]).last
    raise ActiveRecord::RecordNotFound.new("Could not find Collection for id '#{params[:id]}'") unless @collection

    authorize! :destroy, @collection

    if @collection.destroy
      flash[:notice] = I18n.t("txt.controllers.collections.destroy.success")
      redirect_to collections_path
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
