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

class Collections::VersionsController < ApplicationController
  include RdfSyncService::Helper

  def merge
    scope = Iqvoc::Collection.base_class.by_origin(params[:origin])

    current_collection = scope.published.last
    new_version = scope.unpublished.last!

    authorize! :merge, new_version

    ActiveRecord::Base.transaction do
      new_version.rdf_updated_at = nil
      new_version.publish

      if new_version.publishable?
        new_version.save

        if current_collection && !current_collection.destroy
          flash[:error] = t('txt.controllers.versioning.merged_delete_error')
          redirect_to collection_path(new_version, published: 0)
        end

        if Iqvoc.config['triplestore.autosync']
          synced = triplestore_syncer.sync([new_version]) # XXX: blocking
          flash[:warning] = 'triplestore synchronization failed' unless synced # TODO: i18n
        end

        flash[:success] = t('txt.controllers.versioning.published')
        redirect_to collection_path(new_version)
      else
        flash[:error] = t('txt.controllers.versioning.merged_publishing_error')
        redirect_to collection_path(new_version, published: 0)
      end
    end
  end

  def branch
    scope = Iqvoc::Collection.base_class.by_origin(params[:origin])
    current_collection = scope.published.last!

    if draft_collection = scope.unpublished.last
      flash[:info] = t('txt.controllers.versioning.branch_error')
      redirect_to collection_path(published: 0, id: draft_collection)
    else
      authorize! :branch, current_collection

      new_version = nil
      ActiveRecord::Base.transaction do
        new_version = current_collection.branch
        new_version.save!
      end
      flash[:success] = t('txt.controllers.versioning.branched')
      redirect_to edit_collection_path(new_version, published: 0)
    end
  end

  def consistency_check
    collection = Iqvoc::Collection.base_class.
        by_origin(params[:origin]).
        unpublished.
        last!

    authorize! :check_consistency, collection

    if collection.publishable?
      flash[:success] = t('txt.controllers.versioning.consistency_check_success')
      redirect_to collection_path(collection, published: 0)
    else
      flash[:error] = t('txt.controllers.versioning.consistency_check_error')
      redirect_to edit_collection_path(collection, published: 0, full_consistency_check: '1')
    end
  end

  def to_review
    collection = Iqvoc::Collection.base_class.
        by_origin(params[:origin]).
        unpublished.
        last!

    authorize! :send_to_review, collection
    collection.to_review

    collection.save!
    flash[:success] = t('txt.controllers.versioning.to_review_success')
    redirect_to collection_path(collection, published: 0)
  end
end
