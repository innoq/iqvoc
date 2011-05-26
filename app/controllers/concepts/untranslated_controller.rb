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

class Concepts::UntranslatedController < ConceptsController
  skip_before_filter :require_user

  def index
    authorize! :read, Concept::Base

    main_lang = Iqvoc::Concept.pref_labeling_languages.first

    scope = Iqvoc::Concept.pref_labeling_class.label_class.
      begins_with(params[:letter]).
      joins(:concepts).
      joins('LEFT OUTER JOIN labelings pref_labelings ON
          pref_labelings.id <> labelings.id AND
          pref_labelings.owner_id = concepts.id AND
          pref_labelings.type = "%s"' % Iqvoc::Concept.pref_labeling_class_name).
      joins('LEFT OUTER JOIN labels pref_labels ON
          pref_labels.id = pref_labelings.target_id AND
          pref_labels.language = "%s"' % I18n.locale).
      where('labelings.type = "%s"' % Iqvoc::Concept.pref_labeling_class_name).
      where('pref_labels.id IS NULL').
      where('labels.language = "%s"' % main_lang).
      includes(:pref_labeled_concepts)

    if I18n.locale == main_lang
      flash[:error] = I18n.t("txt.views.untranslated_concepts.unavailable")
    else
      @labels = scope.order("LOWER(labels.value)").
          paginate(:page => params[:page], :per_page => 40)
    end
  end

end
