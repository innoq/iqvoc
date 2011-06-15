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

class Label::Base < ActiveRecord::Base

  set_table_name 'labels'

  # ********** Validations

  validates :value, :presence => {:message => I18n.t("txt.models.label.value_error")}

  # ********** Associations

  has_many :labelings, :foreign_key => 'target_id', :class_name => "Labeling::Base"
  has_many :concepts, :through => :labelings, :source => :owner

  has_many :pref_labelings, :foreign_key => 'target_id', :class_name => Iqvoc::Concept.pref_labeling_class_name
  has_many :pref_labeled_concepts, :through => :pref_labelings, :source => :owner

  # ********* Scopes

  scope :by_language, lambda { |lang_code|
    if (lang_code.is_a?(Array) && lang_code.include?(nil))
      where(arel_table[:language].eq(nil).or(arel_table[:language].in(lang_code.compact)))
    elsif lang_code.blank?
      where(arel_table[:language].eq(nil))
    else
      where(:language => lang_code)
    end
  }

  scope :begins_with, lambda { |letter|
    where("LOWER(SUBSTR(#{Label::Base.table_name}.value, 1, 1)) = :letter", :letter => letter.to_s.downcase)
  }

  scope :missing_translation, lambda { |lang, main_lang|
    joins(:concepts).
      joins(sanitize_sql(["LEFT OUTER JOIN labelings pref_labelings ON
          pref_labelings.id <> labelings.id AND
          pref_labelings.owner_id = concepts.id AND
          pref_labelings.type = '%s'", Iqvoc::Concept.pref_labeling_class_name])).
      joins(sanitize_sql(["LEFT OUTER JOIN labels pref_labels ON
          pref_labels.id = pref_labelings.target_id AND
          pref_labels.language = '%s'", lang])).
      where('labelings.type = :class_name', :class_name => Iqvoc::Concept.pref_labeling_class_name).
      where('pref_labels.id IS NULL').
      where('labels.language = :lang', :lang => main_lang).
      includes(:pref_labeled_concepts)
  }

  scope :by_query_value, lambda { |query|
    where(["LOWER(#{table_name}.value) LIKE ?", query.to_s.downcase])
  }

  # Attention: This means that even label classes without version controll will also
  # have to set the published_at flag to be recognized as published!!
  scope :published, lambda {
    where(arel_table['published_at'].not_eq(nil))
  }

  scope :unpublished, lambda { where(arel_table['published_at'].eq(nil)) }

  # ********* Methods

  def published?
    true
  end

  def <=>(other)
    self.to_s.downcase <=> other.to_s.downcase
  end

  def to_literal
    "\"#{value}\"@#{language}"
  end

  def to_s
    if language.to_s != I18n.locale.to_s.strip
      value.to_s + " [#{I18n.t("txt.common.translation_missing_for")} '#{I18n.locale.to_s.strip}']"
    else
      value.to_s
    end
  end

end
