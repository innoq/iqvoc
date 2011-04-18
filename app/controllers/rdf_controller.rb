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

class RdfController < ApplicationController

  skip_before_filter :require_user

  def show
    scope = params[:published] == "0" ? Iqvoc::Concept.base_class.scoped.unpublished : Iqvoc::Concept.base_class.scoped.published
    if @concept = scope.by_origin(params[:id]).with_associations.last
      respond_to do |format|
        format.html {
          redirect_to concept_url(:id => @concept.origin, :lang => I18n.locale, :published => params[:published])
        }
        format.any {
          authorize! :read, @concept
          render "show_concept"
        }
      end
    elsif label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).published.last
      redirect_to label_url(:id => label.origin, :lang => I18n.locale, :published => params[:published])
    else
      raise ActiveRecord::RecordNotFound.new("Coulnd't find either a concept or a label matching '#{params[:id]}'.")
    end
  end

end
