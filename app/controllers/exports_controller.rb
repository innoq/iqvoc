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

  before_action do
    authorize! :export, Concept::Base
  end

  def index
    @export = Export.new
    @exports = Export.order('id DESC')
  end

  def show
    @export = Export.find(params[:id])
  end

  def create
    export = Export.new(params[:export])
    export.user = current_user
    export.token = srand

    if export.save
      filename = export.build_filename
      job = ExportJob.new(export, filename,export.file_type, export.default_namespace)
      Delayed::Job.enqueue(job)

      flash[:success] = t('txt.views.export.success')
    else
      flash[:error] = t('txt.views.export.error')
    end
    redirect_to exports_path
  end

  def download
    export = Export.find(params[:export_id])
    time = export.finished_at.strftime("%Y-%m-%d_%H-%M")

    begin
      send_file export.build_filename,
                filename: "export-#{time}.#{export.file_type}"
    rescue ::ActionController::MissingFile => e
      flash[:error] = t('txt.views.export.missing_file')
      redirect_to exports_path
    end

  end

end
