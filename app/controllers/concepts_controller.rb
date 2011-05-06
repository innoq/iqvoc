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

class ConceptsController < ApplicationController
  skip_before_filter :require_user

  def index
    authorize! :read, Concept::Base
    respond_to do |format|
      format.json do
        @concepts = Iqvoc::Concept.base_class.editor_selectable.with_pref_labels.merge(Label::Base.by_query_value("#{params[:query]}%")).all
        response = []
        @concepts.each { |concept| response << concept_widget_data(concept)}

        render :json => response
      end
      format.all do
        authorize! :full_export, Concept::Base
        @concepts = Iqvoc::Concept.base_class.published
        # When in single query mode, AR handles ALL includes to be loaded by that
        # one query. We don't want that! So let's do it manually :-)
        Concept::Base.send(:preload_associations, @concepts, Iqvoc::Concept.base_class.default_includes + [:notes, {:relations => :target}, {:labelings => :target}])
      end
    end
  end

  def show
    scope = Iqvoc::Concept.base_class.by_origin(params[:id]).with_associations.includes(:collection_members => {:collection => :labels}).includes(Iqvoc::Concept.base_class.default_includes)
    if params[:published] == '1' || !params[:published]
      published = true
      @concept = scope.published.last
      @new_concept_version = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    elsif params[:published] == '0'
      published = false
      @concept = scope.unpublished.last
    end

    raise ActiveRecord::RecordNotFound unless @concept
    authorize! :read, @concept

    respond_to do |format|
      format.html do
        published ? render('show_published') : render('show_unpublished')
      end
      format.ttl
    end
  end

  def new
    authorize! :create, Iqvoc::Concept.base_class
    @concept = Iqvoc::Concept.base_class.new

    Iqvoc::Concept.note_class_names.each do |note_class_name|
      @concept.send(note_class_name.to_relation_name).build if @concept.send(note_class_name.to_relation_name).empty?
    end
  end

  def create
    authorize! :create, Iqvoc::Concept.base_class
    @concept = Iqvoc::Concept.base_class.new(params[:concept])
    if @concept.generate_origin
      if @concept.save
        flash[:notice] = I18n.t("txt.controllers.versioned_concept.success")
        redirect_to concept_path(:published => 0, :id => @concept.origin, :lang => I18n.locale)
      else
        flash.now[:error] = I18n.t("txt.controllers.versioned_concept.error")
        render :new
      end
    else
      flash.now[:error] = I18n.t("txt.controllers.versioned_concept.error")
      render :new
    end
  end

  def edit
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @concept

    authorize! :update, @concept

    if params[:check_associations_in_editing_mode]
      @association_objects_in_editing_mode = @concept.associated_objects_in_editing_mode
    end

    if params[:full_consistency_check]
      @concept.valid_with_full_validation?
    end

    Iqvoc::Concept.note_class_names.each do |note_class_name|
      @concept.send(note_class_name.to_relation_name).build if @concept.send(note_class_name.to_relation_name).empty?
    end
  end

  def update
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @concept
    authorize! :update, @concept

    if @concept.update_attributes(params[:concept])
      flash[:notice] = I18n.t("txt.controllers.versioned_concept.update_success")
      redirect_to concept_path(:published => 0, :id => @concept, :lang => I18n.locale)
    else
      flash.now[:error] = I18n.t("txt.controllers.versioned_concept.update_error")
      render :action => :edit
    end
  end

  def destroy
    @new_concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @new_concept
    authorize! :destroy, @new_concept

    if @new_concept.destroy
      flash[:notice] = I18n.t("txt.controllers.concept_versions.delete")
      redirect_to dashboard_path(:lang => I18n.locale)
    else
      flash[:notice] = I18n.t("txt.controllers.concept_versions.delete_error")
      redirect_to concept_path(:published => 0, :id => @new_concept, :lang => I18n.locale)
    end
  end

end
