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

class Concept::Relation::Base < ActiveRecord::Base

  # ATTENTION:
  # This class (and the inheriting subclasses) should not reference the
  # Concept::Base class directly at load time!
  # This means that Concept::Base may not be loaded when this class is loaded!
  # So use Concept::Base ONLY in methods or procs.
  #
  # The reason for this lies in the fact that Concept::Base calls the
  # Concept::Relation::SKOS::Broader::Base.narrower_class method to create all
  # concept_relation relations. This means Concept::Base triggers Rails to load
  # the Concept::Relation::* classes. If this would trigger Rails to load
  # Concept::Base we would have a loop == a problem.

  self.table_name = 'concept_relations'

  class_attribute :rdf_namespace, :rdf_predicate
  self.rdf_namespace = nil
  self.rdf_predicate = nil

  # ********* Associations

  belongs_to :owner,  :class_name => "Concept::Base"
  belongs_to :target, :class_name => "Concept::Base"

  # ********* Scopes

  def self.by_owner(owner_id)
    where(:owner_id => owner_id)
  end

  def self.by_owner_origin(owner_origin)
    includes(:owner).merge(Concept::Base.by_origin(owner_origin))
  end

  def self.by_target_origin(target_origin)
    includes(:target).merge(Concept::Base.by_origin(target_origin))
  end

  def self.target_editor_selectable
    includes(:target).merge(Concept::Base.editor_selectable)
  end

  def self.published
    includes(:target).merge(Concept::Base.published)
  end

  def self.target_in_edit_mode
    joins(:target).merge(Concept::Base.in_edit_mode)
  end

  # ********* Methods

  def self.reverse_relation_class
    self
  end

  def self.view_section(obj)
    "relations"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/concept/relation/base"
  end

  def self.edit_partial_name(obj)
    "partials/concept/relation/edit_base"
  end

  # if `singular` is true, only a single occurrence is allowed per instance
  def self.singular?
    false
  end

  def rank
    unless self.class.rankable?
      raise "Use `include Rankable` to make a concept relation rankable."
    else
      super
    end
  end

  def rank=(val)
    unless self.class.rankable?
      raise "Use `include Rankable` to make a concept relation rankable."
    else
      super
    end
  end

  def self.rankable?
    self.class.included_modules.include?(Iqvoc::Rankable)
  end

  def self.relation_name
    relname = self.name.underscore.gsub('/', '_').sub('concept_relation_', '')
    Rails.logger.warn "WARN: Inferring relation name #{relname} from class name (#{self.name}), you should define self.relation_name in your relation class."
    relname
  end

end
