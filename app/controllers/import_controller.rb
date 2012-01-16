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

require 'iqvoc/skos_importer'

class ImportController < ApplicationController

  before_filter do
    authorize! :import, Concept::Base
  end

  def index
  end

  def import
    content = params[:ntriples_file] && params[:ntriples_file].read
    strio = StringIO.new
    begin
      Iqvoc::SkosImporter.new(content.to_s.split("\n"), params[:default_namespace], Logger.new(strio))
      @messages = strio.string
    rescue Exception => e
      @messages = e.to_s + "\n\n" + e.backtrace.join("\n")
    end
  end

end
