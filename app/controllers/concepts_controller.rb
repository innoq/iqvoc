# encoding: UTF-8

# Copyright 2011-2014 innoQ Deutschland GmbH
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

require 'concerns/dataset_initialization'

class ConceptsController < ApplicationController
  include DatasetInitialization

  def index
    authorize! :read, Concept::Base

    respond_to do |format|
      format.json do # Search for widget
        scope = Iqvoc::Concept.base_class.editor_selectable.with_pref_labels.
            merge(Label::Base.by_query_value("#{params[:query]}%"))
        scope = scope.where(top_term: false) if params[:exclude_top_terms]
        @concepts = scope.all.map { |concept| concept_widget_data(concept) }
        render json: @concepts
      end
    end
  end

  def show
    scope = Iqvoc::Concept.base_class.by_origin(params[:id]).with_associations

    published = params[:published] == '1' || !params[:published]
    if published
      scope = scope.published
      @new_concept_version = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    else
      scope = scope.unpublished
    end

    @concept = scope.last!

    authorize! :read, @concept

    @datasets = datasets_as_json

    respond_to do |format|
      format.html do
        # When in single query mode, AR handles ALL includes to be loaded by that
        # one query. We don't want that! So let's do it manually :-)
        ActiveRecord::Associations::Preloader.new.preload(@concept,
          Iqvoc::Concept.base_class.default_includes + [collection_members: { collection: :labels },
          broader_relations: { target: [:pref_labels, :broader_relations] },
          narrower_relations: { target: [:pref_labels, :narrower_relations] }])

        published ? render('show_published') : render('show_unpublished')
      end
      format.json do
        # When in single query mode, AR handles ALL includes to be loaded by that
        # one query. We don't want that! So let's do it manually :-)
        ActiveRecord::Associations::Preloader.new.preload(@concept, [:labels,
            { relations: { target: [:labelings, :relations] } }])

        published_relations = lambda { |concept|
          return concept.relations.includes(:target).
            merge(Iqvoc::Concept.base_class.published).references(:concepts)
        }
        concept_data = {
          origin: @concept.origin,
          labels: @concept.labelings.map { |ln| labeling_as_json(ln) },
          relations: published_relations.call(@concept).map { |relation|
            concept = relation.target
            {
              origin: concept.origin,
              labels: concept.labelings.map { |ln| labeling_as_json(ln) },
              relations: published_relations.call(concept).count
            }
          }
        }
        render json: concept_data
      end
      format.any(:ttl, :rdf, :nt)
    end
  end

  def new
    authorize! :create, Iqvoc::Concept.base_class

    @concept = Iqvoc::Concept.base_class.new

    Iqvoc::Concept.note_class_names.each do |note_class_name|
      @concept.send(note_class_name.to_relation_name).build if @concept.send(note_class_name.to_relation_name).empty?
    end

    @concept.notations.build if @concept.notations.none?

    @datasets = datasets_as_json
  end

  def create
    authorize! :create, Iqvoc::Concept.base_class

    @concept = Iqvoc::Concept.base_class.new(concept_params)
    @datasets = datasets_as_json

    if @concept.save
      flash[:success] = I18n.t('txt.controllers.versioned_concept.success')
      redirect_to concept_path(published: 0, id: @concept.origin)
    else
      flash.now[:error] = I18n.t('txt.controllers.versioned_concept.error')
      render :new
    end
  end

  def edit
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last!

    authorize! :update, @concept

    @association_objects_in_editing_mode = @concept.associated_objects_in_editing_mode

    if params[:full_consistency_check]
      @concept.publishable?
    end

    Iqvoc::Concept.note_class_names.each do |note_class_name|
      @concept.send(note_class_name.to_relation_name).build if @concept.send(note_class_name.to_relation_name).empty?
    end

    @concept.notations.build if @concept.notations.none?

    @datasets = datasets_as_json
  end

  def update
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last!

    authorize! :update, @concept

    @datasets = datasets_as_json

    if @concept.update_attributes(concept_params)
      flash[:success] = I18n.t('txt.controllers.versioned_concept.update_success')
      redirect_to concept_path(published: 0, id: @concept)
    else
      flash.now[:error] = I18n.t('txt.controllers.versioned_concept.update_error')
      render action: :edit
    end
  end

  def destroy
    @new_concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last!

    authorize! :destroy, @new_concept

    if @new_concept.destroy
      flash[:success] = I18n.t('txt.controllers.concept_versions.delete')
      redirect_to dashboard_path
    else
      flash[:success] = I18n.t('txt.controllers.concept_versions.delete_error')
      redirect_to concept_path(published: 0, id: @new_concept)
    end
  end

  def move
    moved_concept = Iqvoc::Concept.base_class.find(params.require(:moved_node_id))

    if moved_concept.published?
      authorize! :branch, moved_concept
    else
      authorize! :update, moved_concept
    end

    new_parent_concept = Iqvoc::Concept.base_class.find(params.require(:new_parent_node_id))
    new_parent_concept_version = concept_version(new_parent_concept)

    ActiveRecord::Base.transaction do
      moved_concept_version = concept_version(moved_concept)

      if params[:tree_action] == 'move' && Iqvoc::Concept.root_class.instance.mono_hierarchy?
        if moved_concept.top_term?
          moved_concept_version.update_attribute(:top_term, false)
        else
          # removed old relations
          old_parent_concept = Iqvoc::Concept.base_class.find(params.require(:old_parent_node_id))
          old_parent_concept_version = concept_version(old_parent_concept)

          moved_concept_version.send(Iqvoc::Concept.broader_relation_class_name.to_relation_name)
             .destroy_with_reverse_relation(old_parent_concept_version)

          # delete relations which will be created during branching
          if old_parent_concept_version.narrower_relations.find_by(target_id: moved_concept.id)
            old_parent_concept_version.narrower_relations.find_by(target_id: moved_concept.id).destroy!
          end
          if moved_concept_version.broader_relations.find_by(target_id: old_parent_concept.id)
            moved_concept_version.broader_relations.find_by(target_id: old_parent_concept.id).destroy!
          end
        end
      end

      # add new relations to concept version
      Iqvoc::Concept.broader_relation_class.create! do |r|
        r.owner = moved_concept_version
        r.target = new_parent_concept_version
      end

      Concept::Relation::SKOS::Narrower::Base.create! do |r|
        r.owner = new_parent_concept_version
        r.target = moved_concept_version
      end
    end

    render nothing: true
  end

  before_action :prepare_match, only: [:add_match, :remove_match]

  def add_match
    begin
      @unpublished_concept ||= @published_concept.branch(@current_user)
      @unpublished_concept.save
      @match_class.constantize.create( concept_id: @unpublished_concept.id, value: @uri )
    rescue
      render_response :server_error and return
    ensure
      @unpublished_concept.unlock
    end

    render_response :mapping_added
  end

  def remove_match
    begin
      @unpublished_concept ||= @published_concept.branch(@current_user)
      @unpublished_concept.save
      match = @match_class.constantize.find_by( concept_id: @unpublished_concept.id, value: @uri )
      render_response :unknown_relation and return if match.nil?
      match.destroy
    rescue
      render_response :server_error and return
    ensure
      @unpublished_concept.unlock
    end

    render_response :mapping_removed
  end

  protected

  def prepare_match
    @origin = params.require(:origin)
    @uri = params.require(:uri)

    @match_class = params.require(:match_class)
    match_classes = Iqvoc::Concept.match_class_names
    render_response :unknown_match and return if match_classes.exclude? @match_class

    iqvoc_sources = Iqvoc.config['sources.iqvoc']
    render_response :no_referer and return if request.referer.nil?
    render_response :unknown_referer and return if iqvoc_sources.exclude? request.referer

    @current_user = BotUser.instance
    concept = Iqvoc::Concept.base_class.find_by(origin: @origin)

    if concept.published?
      authorize! :branch, concept
    else
      authorize! :update, concept
    end

    @published_concept = Iqvoc::Concept.base_class.by_origin(@origin).published.last
    @unpublished_concept = Iqvoc::Concept.base_class.by_origin(@origin).unpublished.last
    render_response :concept_locked and return if @unpublished_concept && @unpublished_concept.locked?
  end

  def render_response(type)
    message = messages[type]
    respond_to do |format|
      format.json { render message }
    end
  end

  def messages
    {
      mapping_added:   { status: 200, json: { type: 'concept_mapping_created', message: 'Concept mapping created.'} },
      mapping_removed: { status: 200, json: { type: 'concept_mapping_removed', message: 'Concept mapping removed.'} },
      unknown_relation:{ status: 400, json: { type: 'unknown_relation', message: 'Concept or relation is wrong.'} },
      unknown_match:   { status: 400, json: { type: 'unknown_match', message: 'Unknown match class.' } },
      no_referer:      { status: 400, json: { type: 'no_referer', message: 'Referer is not set.' } },
      unknown_referer: { status: 403, json: { type: 'unknown_referer', message: 'Unknown referer.' } },
      concept_locked:  { status: 423, json: { type: 'concept_locked', message: 'Concept is locked.' } },
      server_error:    { status: 500, json: {} }
    }
  end

  def concept_params
    params.require(:concept).permit!
  end

  # get concept to work with
  # return a new version of the concept or the current draft (if exists)
  def concept_version(concept)
    if concept.published?
      # create a new version
      version = concept.branch(current_user)
      version.save!
    else
      # use current draft concept
      version = concept
    end

    version
  end

  # TODO: rename to match the behavior of the method
  def labeling_as_json(labeling)
    label = labeling.target
    return {
      origin: label.origin,
      reltype: labeling.type.to_relation_name,
      value: label.value,
      lang: label.language
      # TODO: relations (XL only)
    }
  end
end
