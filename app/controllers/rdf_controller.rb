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
  skip_before_filter :set_locale

  def scheme
    respond_to do |format|
      format.html { redirect_to about_path }
      format.any do
        authorize! :read, Iqvoc::Concept.root_class.instance
        @top_concepts = Iqvoc::Concept.base_class.tops.published.all
      end
    end
  end

end
