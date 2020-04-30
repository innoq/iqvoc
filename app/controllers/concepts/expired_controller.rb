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

class Concepts::ExpiredController < Concepts::AlphabeticalController
  protected

  def identify_used_first_letters
    @letters = Label::Base.where("#{Label::Base.table_name}.language = ?", I18n.locale).joins(:pref_labeled_concepts).where("concepts.expired_at < ?", Time.now).where("concepts.type = ?", Iqvoc::Concept.base_class_name).select("DISTINCT UPPER(SUBSTR(value, 1, 1)) AS letter").order("letter").map(&:letter)
  end

  def find_labelings
    query = (params[:prefix] || @letters.first || 'a').mb_chars.downcase.to_s

    Iqvoc::Concept.pref_labeling_class
      .concept_expired
      .label_begins_with(query)
      .by_label_language(I18n.locale)
      .includes(:target)
      .order(Arel.sql("LOWER(#{Label::Base.table_name}.value)"))
      .joins(:owner)
      .where(concepts: { type: Iqvoc::Concept.base_class_name })
      .references(:concepts, :labels, :labelings)
  end
end
