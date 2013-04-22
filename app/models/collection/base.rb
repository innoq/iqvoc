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

class Collection::Base < Concept::Base

  #*********** Associations

  has_many Note::SKOS::Definition.name.to_relation_name,
      :class_name => 'Note::SKOS::Definition',
      :as => :owner,
      :dependent => :destroy

  has_many :members,
      :class_name  => 'Collection::Member::Base',
      :foreign_key => 'collection_id',
      :dependent   => :destroy

  has_many :parent_collection_members,
      :class_name  => 'Collection::Member::Base',
      :foreign_key => 'target_id',
      :dependent   => :destroy
  has_many :parent_collections,
      :through => :parent_collection_members


  #********** Hooks

  after_save :regenerate_concept_members, :regenerate_collection_members

  #********** Scopes

  def self.by_origin(origin)
    where(:origin => origin)
  end

  def self.by_label_value(val)
    includes(:labels).merge(Label::Base.by_query_value(val))
  end

  def self.tops
    includes(:parent_collection_members).
        where("#{Collection::Member::Base.table_name}.target_id IS NULL")
  end

  def self.by_parent_id(parent_id)
    includes(:parent_collection_members).
        where(Collection::Member::Base.arel_table[:collection_id].eq(parent_id))
  end

  #********** Validations

  validate :circular_subcollections

  #********** Methods

  def subcollections
    members.map(&:target).select { |m| m.is_a?(::Collection::Base) }
  end

  def concepts
    members.map(&:target).select { |m| !m.is_a?(::Collection::Base) }
  end

  def additional_info
    concepts.count
  end

  def to_param
    origin
  end

  def label
    pref_label
  end

  def build_rdf_subject(&block)
    IqRdf::Coll::build_uri(self.origin, IqRdf::Skos::build_uri("Collection"), &block)
  end

  def inline_member_concept_origins=(origins)
    @member_concept_origins = origins.to_s.
        split(Iqvoc::InlineDataHelper::SPLITTER).map(&:strip)
  end

  def inline_member_concept_origins
    @member_concept_origins || concepts.map { |m| m.origin }.uniq
  end

  def inline_member_concepts
    if @member_concept_origins
      Concept::Base.editor_selectable.where(:origin => @member_concept_origins)
    else
      concepts.select{|c| c.editor_selectable?}
    end
  end

  def inline_member_collection_origins=(origins)
    @member_collection_origins = origins.to_s.
        split(Iqvoc::InlineDataHelper::SPLITTER).map(&:strip)
  end

  def inline_member_collection_origins
    @member_collection_origins || collections.
        map { |m| m.origin }.uniq
  end

  def inline_member_collections
    if @member_collection_origins
      Collection::Base.where(:origin => @member_collection_origins)
    else
      subcollections
    end
  end

  #********** Hook methods

  def regenerate_members(target_class, target_origins)
    return if target_origins.nil? # There is nothing to do
    existing = self.members.includes(:target)
    existing = if target_class <= Collection::Base
      existing.select { |m| m.target.is_a?(Collection::Base) }
    else
      existing.reject { |m| m.target.is_a?(Collection::Base) }
    end
    new = []
    target_origins.each do |new_origin|
      member = existing.find{ |m| m.target.origin == new_origin }
      unless member
        c = target_class.by_origin(new_origin).first
        member = Iqvoc::Collection.member_class.create(:collection => self, :target => c) if c
      end
      new << member if member
    end
    (existing - new).each do |m|
      m.destroy
    end
  end

  def regenerate_concept_members
    regenerate_members(Concept::Base, @member_concept_origins)
  end

  def regenerate_collection_members
    regenerate_members(Collection::Base, @member_collection_origins)
  end

  #******** Validation methods

  # This only prevent circles of length 2.
  # TODO: This should be a real circle detector (but still performant) or be
  # removed (seems to me like the better idea).
  def circular_subcollections
    Iqvoc::Collection.base_class.by_origin(@member_collection_origins).includes(:members => :target).each do |subcollection|
      if subcollection.subcollections.include?(self)
        errors.add(:base,
          I18n.t("txt.controllers.collections.circular_error", :label => subcollection.pref_label))
      end
    end
  end

  def pref_label_in_primary_thesaurus_language
    labels = self.send(Iqvoc::Concept.pref_labeling_class_name.to_relation_name).map(&:target).select{|l| l.published?}
    if labels.count == 0
      errors.add :base, I18n.t("txt.models.concept.no_pref_label_error")
    elsif not labels.map(&:language).map(&:to_s).include?(Iqvoc::Concept.pref_labeling_languages.first.to_s)
      errors.add :base, I18n.t("txt.models.concept.main_pref_label_language_missing_error")
    end
  end

end
