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

class ExportsController < ApplicationController

  before_filter do
    authorize! :export, Concept::Base
  end

  def index
    @exports = Export.order('id DESC')
  end

  def show
    @export = Export.find(params[:id])
  end

  def create
    export = Export.create!(:user => current_user)
    #
    # job = ImportJob.new(import, content, current_user, params[:default_namespace], params[:publish])
    # Delayed::Job.enqueue(job)
    #
    flash[:success] = t('txt.views.export.success')
    redirect_to exports_path
  end

end
