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

# TODO: This class (including the view) should not exist! Please move this back
# into the alphabetical_controller. The only difference between those two
# controllers is the scope used. Use if statements or published methods instead.
# "DRYness"
class Concepts::UntranslatedController < ConceptsController
  skip_before_filter :require_user

  def index
    authorize! :read, Concept::Base

    scope = Iqvoc::Concept.pref_labeling_class.label_class.
      begins_with(params[:letter]).
      missing_translation(I18n.locale, Iqvoc::Concept.pref_labeling_languages.first)

    if I18n.locale.to_s == Iqvoc::Concept.pref_labeling_languages.first # TODO: Should be 404!
      @labels = []
      flash[:error] = I18n.t("txt.views.untranslated_concepts.unavailable")
    else
      @labels = scope.order("LOWER(labels.value)").page(params[:page])
    end
  end

end
