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

require 'iqvoc/rdf_sync'

class Concepts::VersionsController < ApplicationController
  include Iqvoc::RDFSync::Helper

  def merge
    current_concept = Iqvoc::Concept.base_class.by_origin(params[:origin]).published.last
    new_version = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find unpublished concept with origin '#{params[:origin]}'") unless new_version

    authorize! :merge, new_version

    ActiveRecord::Base.transaction do
      if current_concept.blank? || current_concept.destroy
        new_version.rdf_updated_at = nil
        new_version.publish
        new_version.unlock
        if new_version.valid_with_full_validation?
          new_version.save

          if Iqvoc.config["triplestore_autosync"]
           synced = triplestore_syncer.sync([new_version]) # XXX: blocking
           flash[:warning] = "triplestore synchronization failed" unless synced # TODO: i18n
          end

          flash[:success] = t("txt.controllers.versioning.published")
          redirect_to concept_path(:id => new_version)
        else
          flash[:error] = t("txt.controllers.versioning.merged_publishing_error")
          redirect_to concept_path(:published => 0, :id => new_version)
        end
      else
        flash[:error] = t("txt.controllers.versioning.merged_delete_error")
        redirect_to concept_path(:published => 0, :id => new_version)
      end
    end
  end

  def branch
    current_concept = Iqvoc::Concept.base_class.by_origin(params[:origin]).published.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find published concept with origin '#{params[:origin]}'") unless current_concept
    raise "There already is an unpublished version for concept '#{params[:origin]}'" if Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last

    authorize! :branch, current_concept

    new_version = nil
    ActiveRecord::Base.transaction do
      new_version = current_concept.branch(current_user)
      new_version.save!
    end
    flash[:success] = t("txt.controllers.versioning.branched")
    redirect_to edit_concept_path(:published => 0, :id => new_version)
  end

  def lock
    new_version = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find unpublished concept with origin '#{params[:origin]}'") unless new_version
    raise "Concept with origin '#{params[:origin]}' has already been locked." if new_version.locked?

    authorize! :lock, new_version

    new_version.lock_by_user(current_user.id)
    new_version.save :validate => false

    flash[:success] = t("txt.controllers.versioning.locked")
    redirect_to edit_concept_path(:published => 0, :id => new_version)
  end

  def unlock
    new_version = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find unpublished concept with origin '#{params[:origin]}'") unless new_version
    raise "Concept with origin '#{params[:origin]}' wasn't locked." unless new_version.locked?

    authorize! :unlock, new_version

    new_version.unlock
    new_version.save :validate => false

    flash[:success] = t("txt.controllers.versioning.unlocked")

    redirect_to concept_path(:published => 0, :id => new_version)
  end

  def consistency_check
    concept = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound unless concept

    authorize! :check_consistency, concept

    if concept.valid_with_full_validation?
      flash[:success] = t("txt.controllers.versioning.consistency_check_success")
      redirect_to concept_path(:published => 0, :id => concept)
    else
      flash[:error] = t("txt.controllers.versioning.consistency_check_error")
      redirect_to edit_concept_path(:published => 0, :id => concept, :full_consistency_check => "1")
    end
  end

  def to_review
    concept = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound unless concept

    authorize! :send_to_review, concept

    concept.to_review
    concept.save!
    flash[:success] = t("txt.controllers.versioning.to_review_success")
    redirect_to concept_path(:published => 0, :id => concept)
  end

end
