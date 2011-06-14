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

class TripleStoreSyncsController < ApplicationController

  # TODO: This must definitely be rebuild!

  def new
    authorize! :use, :dashboard # TODO
  end

  def create
    authorize! :use, :dashboard # TODO

    time = Time.now

    rdf_helper = Object.new.extend(RdfHelper)

    Concept::Base.published.unsynced.find_each do |concept|
      concept.update_attribute(:rdf_updated_at, time) if RdfStore.mass_import(concept.rdf_uri, rdf_helper.render_ttl_for_concept(concept))
    end

    Label::Base.published.unsynced.find_each do |label|
      label.update_attribute(:rdf_updated_at, time) if RdfStore.mass_import(label.rdf_uri, rdf_helper.render_ttl_for_label(label))
    end

    flash.now[:notice] = I18n.t("txt.controllers.triple_store_syncs.success")

    render :action => "new"
  end

end
