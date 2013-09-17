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

class RdfController < ApplicationController
  skip_before_filter :set_locale

  def show
    scope = if params[:published] == "0"
      Iqvoc::Concept.base_class.unpublished
    else
      Iqvoc::Concept.base_class.published
    end

    if @concept = scope.by_origin(params[:id]).with_associations.last
      object_path = concept_path(:id => @concept, :published => params[:published])
      object = @concept
      tpl = "concepts/show"
    elsif @collection = Iqvoc::Collection.base_class.by_origin(params[:id]).with_associations.last
      object_path = collection_path(:id => @collection)
      object = @collection
      tpl = "collections/show"
    else
      raise ActiveRecord::RecordNotFound, "Resource not found."
    end

    respond_to do |format|
      format.html do
        redirect_to object_path
      end
      format.any do
        authorize! :read, object
        render tpl
      end
    end
  end

  def void
    respond_to do |format|
      format.any(:rdf, :ttl)
    end
  end

end
