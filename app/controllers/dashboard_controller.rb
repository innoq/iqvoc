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
  def index
    authorize! :use, :dashboard

    Iqvoc.first_level_classes.each do |klass|
      instance_variable_set("@#{klass.model_name.singular}", klass.for_dashboard.load)
    end

    factor = params[:order] == 'desc' ? -1 : 1

    if ['class', 'locking_user', 'follow_up', 'updated_at', 'state'].include?(params[:by])
      @items.sort! do |x, y|
        xval, yval = x.send(params[:by]), y.send(params[:by])
        xval = xval.to_s.downcase
        yval = yval.to_s.downcase
        (xval <=> yval) * factor
      end
    else
      @items.sort! { |x, y| (x.to_s.downcase <=> y.to_s.downcase) * factor } rescue nil
    end

    Iqvoc.first_level_classes.map { |k| instance_variable_get("@#{k.model_name.singular}") }.each { |k| instance_variable_set("@#{k.model_name.singular}", Kaminari.paginate_array(k).page(params[:page])) }

    render 'index', locals: {tab: params[:tab]}
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
end
