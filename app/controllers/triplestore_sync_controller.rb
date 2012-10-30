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

  def index
    authorize! :use, :dashboard

    if Iqvoc.config["triplestore_url"] == Iqvoc.config.defaults["triplestore_url"]
      flash.now[:warning] = I18n.t("txt.controllers.triplestore_sync.config_warning")
    else
      host = Iqvoc.config["triplestore_url"]
      username = Iqvoc.config["triplestore_username"].presence
      password = Iqvoc.config["triplestore_password"].presence
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

    base_url = root_url(:lang => nil) # XXX: brittle in the face of future changes?
    host = URI.parse(Iqvoc.config["triplestore_url"])
    port = host.port
    host.port = 80 # XXX: hack to remove port from serialization
    sync = Iqvoc::RDFSync.new(base_url, host.to_s, :port => port,
        :username => Iqvoc.config["triplestore_username"].presence,
        :password => Iqvoc.config["triplestore_password"].presence)

    if (sync.all rescue false)
      flash[:success] = I18n.t("txt.controllers.triplestore_sync.success")
    else
      flash[:error] = I18n.t("txt.controllers.triplestore_sync.error")
    end

    redirect_to :action => "index"
  end

end
