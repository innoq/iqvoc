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

class DashboardController < ApplicationController
  def concept_index
    authorize! :use, :dashboard

    concepts = Iqvoc::Concept.base_class.for_dashboard.load

    if params[:sort] && params[:sort].include?('state ')
      sort = params[:sort].split(',').select { |s| s.include? 'state ' }.last.gsub('state ', '')
      concepts = concepts.to_a.sort_by { |c| c.state }
      concepts = sort == 'DESC' ? concepts.reverse : concepts
    elsif params[:sort]
      order_params = params[:sort]
      #FIXME: how to order by state in database?
      order_params = sanatize_order order_params
      order_params = order_params.gsub('value', 'labels.value').gsub('locking_user', 'users.surname').gsub('follow_up', 'concepts.follow_up').gsub('updated_at', 'concepts.updated_at')

      concepts = concepts.includes(:pref_labels, :locking_user).references(:locking_user).order(order_params)
    end

    @items = Kaminari.paginate_array(concepts).page(params[:page])

    render 'index', locals: { active_class: Iqvoc::Concept.base_class }
  end

  def collection_index
    authorize! :use, :dashboard

    collections = Iqvoc::Collection.base_class.for_dashboard.load

    if params[:sort] && params[:sort].include?('state ')
      sort = params[:sort].split(',').select { |s| s.include? 'state ' }.last.gsub('state ', '')
      collections = collections.to_a.sort_by { |c| c.state }
      collections = sort == 'DESC' ? collections.reverse : collections
    elsif params[:sort]
      order_params = sanatize_order params[:sort]
      order_params = order_params.gsub('value', 'labels.value').gsub('locking_user', 'users.surname').gsub('updated_at', 'concepts.updated_at')

      collections = collections.includes(:pref_labels, :locking_user).references(:locking_user).order(order_params)
    end

    @items = Kaminari.paginate_array(collections).page(params[:page])

    render 'index', locals: { active_class: Iqvoc::Collection.base_class }
  end

  def glance
    authorize! :use, :dashboard
    objects = params[:type].constantize.by_origin(params[:origin])
    object = objects.send(params[:published] == "1" ? 'published' : 'unpublished').first

    @title = object.to_s
    @editorial_notes = Note::SKOS::EditorialNote.where(owner_id: object.id, owner_type: object.class)

    @path = send(object.class_path, id: object, published: params[:published])

    respond_to do |format|
      format.html do
        render layout: false
      end
    end
  end

  def reset
    authorize! :reset, :thesaurus

    if request.post?
      DatabaseCleaner.strategy = :truncation, {
        except: Iqvoc.truncation_blacklist
      }
      DatabaseCleaner.clean

      flash.now[:success] = t('txt.views.dashboard.reset_success')
    else
      flash.now[:danger] = t('txt.views.dashboard.reset_warning')
      flash.now[:error] = t('txt.views.dashboard.jobs_pending_warning') if Delayed::Job.any?
    end
  end

  private

  def sanatize_order search_params
    return '' if search_params.include?(';')
    param_array = search_params.split(',').compact.select do |order_column|
      column_and_order = order_column.split(' ')
      column_and_order.count == 2 && ['value', 'locking_user', 'follow_up', 'updated_at'].include?(column_and_order[0]) && ['ASC', 'DESC'].include?(column_and_order[1])
    end
    param_array.join(',')
  end
end
