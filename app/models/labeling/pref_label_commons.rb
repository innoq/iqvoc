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

module Labeling
  module PrefLabelCommons
    extend ActiveSupport::Concern

    included do

      validate do
        oid = self.owner_id || (self.owner && self.owner.id)
        break unless oid
        languages = {self.target.language.to_s => self.target.origin.to_s}
        self.class.where(:owner_id => oid).includes(:target).each do |pref_labeling|
          lang = pref_labeling.target.language.to_s
          origin = pref_labeling.target.origin.to_s
          if (languages.keys.include?(lang) && languages[lang] != origin)
            errors.add(:base, I18n.t("txt.models.concept.pref_labels_with_same_languages_error"))
          end
          languages[lang] = origin
        end
      end
    
    end

  end
end