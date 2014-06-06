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

class Labeling::Base < ActiveRecord::Base
  self.table_name = 'labelings'

  class_attribute :rdf_namespace, :rdf_predicate
  self.rdf_namespace = nil
  self.rdf_predicate = nil

  # ********** Associations

  belongs_to :owner,  class_name: 'Concept::Base'
  belongs_to :target, class_name: 'Label::Base'

  # ********** Scopes

  def self.by_concept(concept)
    where(owner_id: concept.id)
  end

  def self.by_label(label)
    where(target_id: label.id)
  end

  def self.concept_published
    includes(:owner).merge(Concept::Base.published)
  end

  def self.concept_expired
    includes(:owner).merge(Iqvoc::Concept.base_class.expired)
  end

  def self.concept_not_expired
    includes(:owner).merge(Iqvoc::Concept.base_class.not_expired)
  end

  def self.label_published
    includes(:target).merge(Label::Base.published)
  end

  def self.label_begins_with(prefix)
    includes(:target).merge(Label::Base.begins_with(prefix))
  end

  def self.by_label_language(lang)
    includes(:target).merge(Label::Base.by_language(lang.to_s)).references(:labels)
  end

  # ********** Methods

  # if `singular` is true, only a single occurrence is allowed per instance
  # FIXME: There must be a validation checking this
  # Might there be more than one labeling of this type and language per concept?
  def self.singular?
    false
  end

  def self.view_section(obj)
    obj.is_a?(Label::Base) ? 'concepts' : 'labels'
  end

  def self.view_section_sort_key(obj)
    200
  end

  def self.partial_name(obj)
    'partials/labeling/base'
  end

  def self.edit_partial_name(obj)
    'partials/labeling/edit_base'
  end
end
