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

class TriplestoreSyncController < ApplicationController
  include Iqvoc::RDFSync::Helper

  def index
    authorize! :use, :dashboard

    if Iqvoc.config["triplestore.url"] == Iqvoc.config.defaults["triplestore.url"]
      flash.now[:warning] = I18n.t("txt.controllers.triplestore_sync.config_warning")
    else
      host = Iqvoc.config["triplestore.url"]
      username = Iqvoc.config["triplestore.username"].presence
      password = Iqvoc.config["triplestore.password"].presence
      target_info = host
      if username && password
        target_info = "#{target_info} (as #{username} with password)" # XXX: i18n
      elsif username
        target_info = "#{target_info} (as #{username})" # XXX: i18n
      end
      flash.now[:info] = I18n.t("txt.controllers.triplestore_sync.config_info",
          :target_info => target_info)
    end

    # per-class pagination
    @candidates = Iqvoc::RDFSync.candidates.map do |records|
      records.page(params[:page])
    end
  end

  def sync
    authorize! :use, :dashboard

    success = triplestore_syncer.all # XXX: long-running

    if success
      flash[:success] = I18n.t("txt.controllers.triplestore_sync.success")
    else
      flash[:error] = I18n.t("txt.controllers.triplestore_sync.error")
    end

    redirect_to :action => "index"
  end

end
