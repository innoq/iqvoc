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

class Concept::Base < ActiveRecord::Base

  self.table_name = 'concepts'

  include Iqvoc::Versioning

  class_attribute :default_includes
  self.default_includes = []

  include ActsAsRdfClass

  include Concept::Validations

  Iqvoc::Concept.include_modules.each do |mod|
    include mod
  end

  include InlineNotesHandling
  include InlineRelationsHandling
  include InlineLabelingsHandling

  # ********** Hooks

  after_initialize do
    @full_validation = false
    @associated_objects_marked_for_destruction ||= []
  end

  after_save :generate_origin_if_blank

  before_save :destroy_associated_objects_marked_for_destruction

  # ********** "Static"/unconfigureable relations

  @nested_relations = [] # Will be marked as nested attributes later

  has_many :relations,
      :foreign_key => 'owner_id',
      :class_name  => 'Concept::Relation::Base',
      :dependent   => :destroy,
      :extend      => [Concept::TypedHasManyExtension, RelationSubtypeExtensions]

  has_many :related_concepts, :through => :relations, :source => :target
  has_many :referenced_relations, :foreign_key => 'target_id', :class_name => 'Concept::Relation::Base', :dependent => :destroy
  include_to_deep_cloning(:relations, :referenced_relations)

  has_many :labelings,
      :foreign_key => 'owner_id',
      :class_name  => 'Labeling::Base',
      :dependent   => :destroy,
      :extend      => [Concept::TypedHasManyExtension, LabelingSubtypeExtensions]
  has_many :labels, :through => :labelings, :source => :target
  include_to_deep_cloning(:labelings => :target)

  has_many :notes,
      :class_name => 'Note::Base',
      :as         => :owner,
      :dependent  => :destroy,
      :extend     => [Concept::TypedHasManyExtension]
  include_to_deep_cloning(:notes => :annotations)

  has_many :matches, :foreign_key => 'concept_id', :class_name => 'Match::Base', :dependent => :destroy
  include_to_deep_cloning(:matches)

  has_many :collection_members,
      :foreign_key => 'target_id',
      :class_name  => 'Collection::Member::Base',
      :dependent   => :destroy
  has_many :collections, :through => :collection_members, :class_name => Iqvoc::Collection.base_class_name
  include_to_deep_cloning(:collection_members)

  has_many :notations, :class_name => 'Notation::Base', :foreign_key => 'concept_id', :dependent => :destroy
  include_to_deep_cloning :notations
  @nested_relations << :notations

  # ************** "Dynamic"/configureable relations

  # *** Concept2Concept relations

  # Broader -- NOTE: read-only!
  def broader_relations
    self.relations.for_class(Iqvoc::Concept.broader_relation_class_name)
  end

  def broader_relations=(foo)
    raise NotImplementedError
  end

  # Narrower -- NOTE: read-only!
  def narrower_relations
    self.relations.for_class(Iqvoc::Concept.broader_relation_class.reverse_relation_class)
  end

  def narrower_relations=(foo)
    raise NotImplementedError
  end

  # *** Labels/Labelings

  def pref_labelings
    self.labelings.for_class(Iqvoc::Concept.pref_labeling_class_name)
  end

  def pref_labelings=(*args)
    raise NotImplementedError
  end

  def pref_labels
    self.pref_labelings.map(&:target).compact
  end

  def pref_labels=(*args)
    raise NotImplementedError
  end

  # *** Matches (pointing to an other thesaurus)

  Iqvoc::Concept.match_class_names.each do |match_class_name|
    has_many match_class_name.to_relation_name,
      :class_name  => match_class_name,
      :foreign_key => 'concept_id'

    # Serialized setters and getters (\r\n or , separated) -- TODO: use Iqvoc::InlineDataHelper?
    define_method("inline_#{match_class_name.to_relation_name}".to_sym) do
      self.send(match_class_name.to_relation_name).map(&:value).join("\r\n")
    end

    define_method("inline_#{match_class_name.to_relation_name}=".to_sym) do |value|
      urls = value.split(/\r\n|,/).map(&:strip).reject(&:blank?)
      self.send(match_class_name.to_relation_name).each do |match|
        if (urls.include?(match.value))
          urls.delete(match.value) # We're done with that one
        else
          self.send(match_class_name.to_relation_name).destroy(match.id) # User deleted this one
        end
      end
      urls.each do |url|
        self.send(match_class_name.to_relation_name) << match_class_name.constantize.new(:value => url)
      end
    end
  end

  # *** Further association classes (could be ranks or stuff like that)

  Iqvoc::Concept.additional_association_classes.each do |association_class, foreign_key|
    has_many association_class.name.to_relation_name, :class_name => association_class.name, :foreign_key => foreign_key, :dependent => :destroy
    include_to_deep_cloning(association_class.deep_cloning_relations)
    association_class.referenced_by(self)
  end

  # ********** Relation Stuff

  @nested_relations.each do |relation|
    accepts_nested_attributes_for relation, :allow_destroy => true, :reject_if => Proc.new { |attrs| attrs[:value].blank? }
  end

  # ********** Scopes

  def self.tops
    where(:top_term => true)
  end

  def self.broader_tops
    includes(:relations, :labels).
    where(:concept_relations => { :id => nil },
      :labelings => { :type => Iqvoc::Concept.pref_labeling_class_name }).
    order("LOWER(#{Label::Base.table_name}.value)")
  end

  def self.with_associations
    includes [{ :labelings => :target }, :relations, :matches, :notes]
  end

  def self.with_pref_labels
    includes(:labels).
    order("LOWER(#{Label::Base.table_name}.value)").
    where(:labelings => { :type => Iqvoc::Concept.pref_labeling_class_name }) # This line is just a workaround for a Rails Bug. TODO: Delete it when the Bug is fixed
  end

  def self.for_dashboard
    unpublished_or_follow_up.includes(:labelings, :locking_user)
  end

  # ********** Class methods

  def self.inline_partial_name
    'partials/concept/inline_base'
  end

  def self.new_link_partial_name
    'partials/concept/new_link_base'
  end

  def self.edit_link_partial_name
    'partials/concept/edit_link_base'
  end

  # ********** Methods

  def labels_for_class_and_language(rdf_labeling_class, lang = 'en', only_published = true)
    # Convert lang to string in case it's not nil.
    # nil values play their own role for labels without a language.
    lang = lang == 'none' ? nil : lang.to_s
    @labels ||= self.labelings.each_with_object({}) do |labeling, hash|
      subhash = hash[labeling.rdf_internal_name] ||= {}
      arr = subhash[labeling.target.language] ||= []
      arr << labeling.target if labeling.target
    end
    ((@labels && @labels[rdf_labeling_class] && @labels[rdf_labeling_class][lang]) || []).select{|l| l.published? || !only_published}
  end

  def relations_by_id_and_rank(relation_rdf_type)
    ActiveSupport::Deprecation.warn 'please call concept.relations.by_id_and_rank(relation_name) in the future'
    self.relations.by_id_and_rank(relation_rdf_type)
  end

  # returns the (one!) preferred label of a concept for the requested language.
  # lang can either be a (lowercase) string or symbol with the (ISO ....) two letter
  # code of the language (e.g. :en for English, :fr for French, :de for German).
  # If no prefLabel for the requested language exists, a new label will be returned
  # (if you modify it, don't forget to save it afterwards!)
  def pref_label
    lang = I18n.locale.to_s == 'none' ? nil : I18n.locale.to_s
    @cached_pref_labels ||= self.pref_labels.each_with_object({}) do |label, hash|
      if hash[label.language]
        Rails.logger.warn("Two pref_labels (#{hash[label.language]}, #{label}) for one language (#{label.language}). Taking the second one.")
      end
      hash[label.language] = label
    end

    if @cached_pref_labels[lang].nil?
      # Fallback to the main language
      @cached_pref_labels[lang] = self.pref_labels.find do |l|
        l.language.to_s == Iqvoc::Concept.pref_labeling_languages.first.to_s
      end
    end
    @cached_pref_labels[lang]
  end

  def related_concepts_for_relation_class(relation_class, only_published = true)
    res = relations.for_class(relation_class).map(&:target)
    only_published ? res.select(&:published?) : res
  end

  def matches_for_class(match_class)
    match_class = match_class.name if match_class < ActiveRecord::Base # Use the class name string
    matches.select{ |match| match.class.name == match_class }
  end

  def notations_for_class(notation_class)
    notation_class = notation_class.name if notation_class < ActiveRecord::Base # Use the class name string
    notations.select{ |notation| notation.class.name == notation_class }
  end

  # This shows up (in brackets) to the right of a concept link if it doesn't
  # return nil
  def additional_info
    nil
  end

  def to_param
    "#{origin}"
  end

  def to_s
    pref_label.to_s
  end

  # TODO: rename to "publish!" # better: use proper workflow implementation
  def save_with_full_validation!
    @full_validation = true
    save!
  end

  # TODO: rename to "publishable?" # better: use proper workflow implementation
  def valid_with_full_validation?
    @full_validation = true
    valid?
  end

  # TODO: remove
  def invalid_with_full_validation?
    @full_validation = true
    invalid?
  end

  def associated_objects_in_editing_mode
    { :concept_relations => Concept::Relation::Base.by_owner(id).target_in_edit_mode }
  end

  protected

  # Generate a new origin if none was given yet
  def generate_origin_if_blank
    if self.origin.blank?
      raise 'Concept::Base#after_save (generate origin): Unable to set the origin by id!' unless self.id
      self.reload
      self.origin = sprintf('_%08d', self.id)
      self.save! # On exception the complete save transaction will be rolled back
    end
  end

  def mark_for_destruction(associated_object)
    @associated_objects_marked_for_destruction << associated_object
  end

  def destroy_associated_objects_marked_for_destruction
    @associated_objects_marked_for_destruction.each &:destroy
    @associated_objects_marked_for_destruction = []
  end

end
