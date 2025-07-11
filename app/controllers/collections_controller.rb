# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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
  def index
    authorize! :read, Iqvoc::Collection.base_class

    scope = Iqvoc::Collection.base_class
                             .with_pref_labels
                             .published
                             .not_expired

    respond_to do |format|
      format.html do
        @top_collections = if params[:root].present?
                             scope.by_parent_id(params[:root])
                           else
                             scope.tops
                           end

        @top_collections.to_a.sort! { |a, b| a.pref_label.to_s <=> b.pref_label.to_s }

        Iqvoc::Collection.base_class.preload(@top_collections, { members: :target })
      end
      format.json do # For the widget and treeview
        response = if params[:root].present?
          collections = scope.by_parent_id(params[:root])
                             .sort_by { |c| c.pref_label.to_s }

          collections.map do |collection|
            {
              id: collection.id,
              url: collection_path(id: collection, format: :html),
              name: CGI.escapeHTML(collection.pref_label.to_s),
              load_on_demand: collection.subcollections.any?,
              additionalText: collection.additional_info&.then { |info| " (#{info})" }
            }.compact
          end
        else
          scope.merge(Label::Base.by_query_value("#{params[:query]}%"))
               .sort_by { |c| c.pref_label.to_s }
               .map { |c| collection_widget_data(c) }
        end
        render json: response
      end
    end
  end

  def show
    published = params[:published] == '1' || !params[:published]
    scope = Iqvoc::Collection.base_class.by_origin(params[:id])

    if published
      scope = scope.published
      @new_collection_version = Iqvoc::Collection.base_class.by_origin(params[:id]).unpublished.last
    else
      scope = scope.unpublished
    end

    @collection = scope.last!
    authorize! :read, @collection

    # When in single query mode, AR handles ALL includes to be loaded by that
    # one query. We don't want that! So let's do it manually :-)
    Iqvoc::Collection.base_class.preload(@collection,
      [:pref_labels,
        { members: { target: [:pref_labels] + Iqvoc::Collection.base_class.default_includes } }])

    respond_to do |format|
      format.html { published ? render('show_published') : render('show_unpublished') }
      format.any(:rdf, :ttl, :nt)
    end
  end

  def new
    authorize! :create, Iqvoc::Collection.base_class

    @collection = Iqvoc::Collection.base_class.new
    build_note_relations
  end

  def create
    authorize! :create, Iqvoc::Collection.base_class

    @collection = Iqvoc::Collection.base_class.new(collection_params)

    if @collection.save
      flash[:success] = I18n.t('txt.controllers.collections.save.success')
      redirect_to collection_path(published: 0, id: @collection.origin)
    else
      flash.now[:error] = I18n.t('txt.controllers.collections.save.error')
      render :new
    end
  end

  def edit
    @collection = Iqvoc::Collection.base_class.by_origin(params[:id]).last!
    authorize! :update, @collection

    # When in single query mode, AR handles ALL includes to be loaded by that
    # one query. We don't want that! So let's do it manually :-)
    Iqvoc::Collection.base_class.preload(@collection, [
        :pref_labels,
        { members: { target: [:pref_labels] + Iqvoc::Concept.base_class.default_includes } }])

    build_note_relations
  end

  def update
    @collection = Iqvoc::Collection.base_class.by_origin(params[:id]).last!
    authorize! :update, @collection

    # set to_review to false if someone edits a concepts
    collection_params["to_review"] = "false"

    if @collection.update(collection_params)
      flash[:success] = I18n.t('txt.controllers.collections.save.success')
      redirect_to collection_path(@collection, published: 0)
    else
      flash.now[:error] = I18n.t('txt.controllers.collections.save.error')
      render :edit
    end
  end

  def destroy
    @collection = Iqvoc::Collection.base_class.by_origin(params[:id]).last!
    authorize! :destroy, @collection

    if @collection.destroy
      flash[:success] = I18n.t('txt.controllers.collections.destroy.success')
      redirect_to collections_path
    else
      flash.now[:error] = I18n.t('txt.controllers.collections.destroy.error')
      render action: :show
    end
  end

  private

  def collection_params
    params.require(:concept).permit!
  end

  def build_note_relations
    @collection.note_skos_definitions.build if @collection.note_skos_definitions.empty?
  end
end
