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

class ConceptsController < ApplicationController
  include DatasetInitialization

  def index
    authorize! :read, Concept::Base

    respond_to do |format|
      format.html do
        redirect_to hierarchical_concepts_url
      end
      format.json do # Search for widget
        labels_scope = Label::Base.by_query_value("%#{params[:query]}%")
        labels_scope = labels_scope.merge(Label::Base.by_language(params[:language])) if params[:language].present?

        scope = Iqvoc::Concept.base_class
                              .editor_selectable
                              .with_pref_labels
                              .merge(labels_scope)
        scope = scope.where(top_term: false) if params[:exclude_top_terms]

        @concepts = scope.uniq.map { |concept| concept_widget_data(concept) }
        render json: @concepts
      end
    end
  end

  def show
    get_concept
    authorize! :read, @concept

    if params[:full_consistency_check] && can?(:check_consistency, @concept)
      @concept.publishable?
    end

    @datasets = datasets_as_json
    respond_to do |format|
      format.html do

        jobs = @concept.jobs
        if jobs.any?
          match_classes = Iqvoc::Concept.reverse_match_class_names

          @jobs = jobs.map do |j|
            handler = YAML.load(j.handler)
            match_class_name = match_classes.key(handler.match_class)
            reverse_match_class_name = match_class_name.constantize.reverse_match_class_name
            reverse_match_class_label = reverse_match_class_name.constantize.rdf_predicate.camelize if reverse_match_class_name

            result = {response_error: j.error_message}
            result[:subject] = handler.subject
            result[:type] = handler.type
            result[:match_class] = reverse_match_class_label || reverse_match_class_name
            result
          end
        end

        Iqvoc::Concept.base_class.preload(
          @concept, Iqvoc::Concept.base_class.default_includes + [
          collection_members: { collection: :labels },
          broader_relations: { target: [:pref_labels, :broader_relations] },
          narrower_relations: { target: [:pref_labels, :narrower_relations] }
        ])

        @published ? render('show_published') : render('show_unpublished')
      end
      format.json do
        # When in single query mode, AR handles ALL includes to be loaded by that
        # one query. We don't want that! So let's do it manually :-)
        Iqvoc::Concept.base_class.preload(@concept, [:labels,
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
          },
          links: [
            { rel: 'self', href: concept_url(@concept, format: nil), method: 'get' },
            { rel: 'add_match', href: add_match_url(@concept, lang: nil), method: 'patch' },
            { rel: 'remove_match', href: remove_match_url(@concept, lang: nil), method: 'patch' }
          ]
        }
        # FIXME: use jbuilder instead???
        render json: concept_data
      end
      format.any(:ttl, :rdf, :nt)
    end
  end

  def glance
    get_concept
    authorize! :read, @concept

    respond_to do |format|
      format.html do
        @view = ConceptView.new(@concept, self)
        render layout: false
      end
    end
  end

  def new
    authorize! :create, Iqvoc::Concept.base_class

    @concept = Iqvoc::Concept.base_class.new

    # initial created-ChangeNote creation
    @concept.send(Iqvoc::change_note_class_name.to_relation_name).new do |change_note|
      change_note.value = I18n.t('txt.views.versioning.initial_version')
      change_note.language = I18n.locale.to_s
      change_note.position = 1
      change_note.annotations_attributes = [
        { namespace: 'dct', predicate: 'creator', value: current_user.name },
        { namespace: 'dct', predicate: 'created', value: DateTime.now.to_s }
      ]
    end

    Iqvoc::Concept.note_class_names.each do |note_class_name|
      @concept.send(note_class_name.to_relation_name).build if @concept.send(note_class_name.to_relation_name).empty?
    end

    @concept.notations.build if @concept.notations.none?

    @datasets = datasets_as_json
  end

  def create
    authorize! :create, Iqvoc::Concept.base_class

    @concept = Iqvoc::Concept.base_class.new
    @concept.reverse_match_service = Services::ReverseMatchService.new(request.host, request.protocol) if match_sync_enabled?
    @concept.assign_attributes(concept_params)
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

    Iqvoc::Concept.note_class_names.each do |note_class_name|
      @concept.send(note_class_name.to_relation_name).build if @concept.send(note_class_name.to_relation_name).empty?
    end

    @concept.notations.build if @concept.notations.none?

    @datasets = datasets_as_json
  end

  def update
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last!
    authorize! :update, @concept
    @concept.reverse_match_service = Services::ReverseMatchService.new(request.host, request.protocol) if match_sync_enabled?

    @datasets = datasets_as_json

    # set to_review to false if someone edits a concepts
    concept_params["to_review"] = "false"

    if @concept.update(concept_params)
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
      published_concept = Iqvoc::Concept.base_class.published.by_origin(@new_concept.origin).first
      flash[:success] = I18n.t('txt.controllers.concept_versions.delete')
      redirect_to published_concept.present? ? concept_path(id: published_concept.origin) : dashboard_path
    else
      flash[:success] = I18n.t('txt.controllers.concept_versions.delete_error')
      redirect_to concept_path(published: 0, id: @new_concept)
    end
  end

  protected

  def get_concept
    scope = Iqvoc::Concept.base_class.by_origin(params[:id]).with_associations

    @published = params[:published] == '1' || !params[:published]
    if @published
      scope = scope.published
      @new_concept_version = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    else
      scope = scope.unpublished
    end

    @concept = scope.last!
  end

  def concept_params
    params.require(:concept).permit!
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

  private

  def match_sync_enabled?
    Iqvoc.config['sources.create_reverse_matches']
  end
end
