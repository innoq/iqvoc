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

class Concepts::VersionsController < ApplicationController
  include RDFSyncService::Helper

  def merge
    concept_scope = Iqvoc::Concept.base_class.by_origin(params[:origin])

    current_concept = concept_scope.published.last
    new_version = concept_scope.unpublished.last

    unless new_version
      raise ActiveRecord::RecordNotFound,
          "Can't find draft concept with origin '#{params[:origin]}'"
    end

    authorize! :merge, new_version

    ActiveRecord::Base.transaction do
      new_version.rdf_updated_at = nil
      new_version.publish
      new_version.unlock
      if new_version.publishable?
        new_version.save

        if current_concept && !current_concept.destroy
          flash[:error] = t('txt.controllers.versioning.merged_delete_error')
          redirect_to concept_path(published: 0, id: new_version)
        end

        if Iqvoc.config['triplestore.autosync']
         synced = triplestore_syncer.sync([new_version]) # XXX: blocking
         flash[:warning] = 'triplestore synchronization failed' unless synced # TODO: i18n
        end

        flash[:success] = t('txt.controllers.versioning.published')
        redirect_to concept_path(id: new_version)
      else
        flash[:error] = t('txt.controllers.versioning.merged_publishing_error')
        redirect_to concept_path(published: 0, id: new_version)
      end
    end
  end

  def branch
    concept_scope = Iqvoc::Concept.base_class.by_origin(params[:origin])
    current_concept = concept_scope.published.last!

    if draft_concept = concept_scope.unpublished.last
      flash[:info] = t('txt.controllers.versioning.branch_error')
      redirect_to concept_path(published: 0, id: draft_concept)
    else
      authorize! :branch, current_concept

      new_version = nil
      ActiveRecord::Base.transaction do
        new_version = current_concept.branch(current_user)
        new_version.save!
        Iqvoc.change_note_class.create! do |note|
          note.owner = new_version
          note.language = I18n.locale.to_s
          note.annotations_attributes = [
            { namespace: 'dct', predicate: 'creator', value: current_user.name },
            { namespace: 'dct', predicate: 'modified', value: DateTime.now.to_s }
          ]
        end
      end
      flash[:success] = t('txt.controllers.versioning.branched')
      redirect_to edit_concept_path(published: 0, id: new_version)
    end
  end

  def lock
    new_version = Iqvoc::Concept.base_class.
        by_origin(params[:origin]).
        unpublished.
        last!

    if new_version.locked?
      raise "Concept with origin '#{new_version.origin}' is already locked."
    end

    authorize! :lock, new_version

    new_version.lock_by_user(current_user.id)
    new_version.save validate: false

    flash[:success] = t('txt.controllers.versioning.locked')
    redirect_to edit_concept_path(published: 0, id: new_version)
  end

  def unlock
    new_version = Iqvoc::Concept.base_class.
        by_origin(params[:origin]).
        unpublished.
        last!

    unless new_version.locked?
      raise "Concept with origin '#{new_version.origin}' is not locked."
    end

    authorize! :unlock, new_version

    new_version.unlock
    new_version.save validate: false

    flash[:success] = t('txt.controllers.versioning.unlocked')

    redirect_to concept_path(published: 0, id: new_version)
  end

  def consistency_check
    concept = Iqvoc::Concept.base_class.
        by_origin(params[:origin]).
        unpublished.
        last!

    authorize! :check_consistency, concept

    if concept.publishable?
      flash[:success] = t('txt.controllers.versioning.consistency_check_success')
      redirect_to concept_path(published: 0, id: concept)
    else
      flash[:error] = t('txt.controllers.versioning.consistency_check_error')
      redirect_to edit_concept_path(published: 0, id: concept, full_consistency_check: '1')
    end
  end

  def to_review
    concept = Iqvoc::Concept.base_class.
        by_origin(params[:origin]).
        unpublished.
        last!

    authorize! :send_to_review, concept
    concept.to_review

    authorize! :unlock, concept
    concept.unlock

    concept.save!
    flash[:success] = t('txt.controllers.versioning.to_review_success')
    redirect_to concept_path(published: 0, id: concept)
  end
end
