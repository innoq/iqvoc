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

class ImportsController < ApplicationController
  before_action do
    authorize! :import, Concept::Base
  end

  def index
    @import = Import.new
    @imports = Import.order('id DESC')
  end

  def show
    @import = Import.find(params[:id])
  end

  def create
    import = Import.new(import_params)
    import.user = current_user

    if import.save
      job = ImportJob.new(import, import.import_file.current_path, current_user,
                          import.default_namespace, import.publish)

      Delayed::Job.enqueue(job)
      flash[:success] = t('txt.views.import.success')
    else
      flash[:error] = t('txt.views.import.error')
    end
    redirect_to imports_path
  end

  private
  def import_params
    params.require(:import).except!(:user_id, :user).permit!
  end
end
