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

class Concept::Base < ActiveRecord::Base

  self.table_name = 'concepts'

  include Publishable
  include Versioning

  class_attribute :default_includes
  self.default_includes = []

  class_attribute :rdf_namespace, :rdf_class
  self.rdf_namespace = nil
  self.rdf_class = nil

  include Concept::Validations

  Iqvoc::Concept.include_modules.each do |mod|
    include mod
  end

  # ********** Hooks

  before_validation do |concept|
    # Handle save or destruction of inline relations (relations or labelings)
    # for use with widgets etc.

    # Inline assigned SKOS::Labels
    # @labelings_by_text # => {'relation_name' => {'lang' => 'label1, label2, ...'}}
    (@labelings_by_text ||= {}).each do |relation_name, lang_values|
      relation_name = relation_name.to_s
      reflection = self.class.reflections.stringify_keys[relation_name]
      labeling_class = reflection && reflection.class_name && reflection.class_name.constantize
      if labeling_class && labeling_class < Labeling::Base
        self.send(relation_name).destroy_all
        lang_values = { nil => lang_values.first } if lang_values.is_a?(Array) # For language = nil: <input name=bla[labeling_class][]> => Results in an Array! -- XXX: obsolete/dupe (cf `labelings_by_text=`)?
        lang_values.each do |lang, inline_values|
          lang = nil if lang.to_s == 'none'
          Iqvoc::InlineDataHelper.parse_inline_values(inline_values).each do |value|
            value.squish!
            unless value.blank?
              self.send(relation_name).build(:target => labeling_class.label_class.new(:value => value, :language => lang))
            end
          end
        end
      end
    end
  end

  after_save do |concept|
    # Process inline relations
    #
    # NB: rankable relations' target origins may include an embedded rank,
    # delimited by a colon
    #
    # Examples:
    # regular:  {'relation_name' => ['origin1', 'origin2']}
    # rankable: {'relation_name' => ['origin1:100', 'origin2:90']}
    (@concept_relations_by_id ||= {}).each do |relation_name, new_origins|
      # Split comma-separated origins and clean up parameter strings
      new_origins = new_origins.split(Iqvoc::InlineDataHelper::SPLITTER).map(&:squish)

      # Extract embedded ranks (if any) from origin strings (e.g. "origin1:100")
      # => { 'origin1' => nil, 'origin2' => 90 }
      new_origins = new_origins.each_with_object({}) do |e, hsh|
        key, value = e.split(":") # NB: defaults to nil if no rank is provided
        hsh[key] = value
      end

      existing_origins = concept.send(relation_name).map { |r| r.target.origin }.uniq

      # Destroy elements of the given concept relation
      concept.send(relation_name).by_target_origin(existing_origins).each do |relation|
        concept.send(relation_name).destroy_with_reverse_relation(relation.target)
      end

      # Rebuild concept relations
      # This is necessary because changing the rank of an already assigned relation
      # would otherwise be ignored.
      Concept::Base.by_origin(new_origins.keys).each do |c|
        concept.send(relation_name).create_with_reverse_relation(c, :rank => new_origins[c.origin])
      end
    end
  end

  after_save do |concept|
    # Generate a origin if none was given yet
    if concept.origin.blank?
      raise "Concept::Base#after_save (generate origin): Unable to set the origin by id!" unless concept.id
      concept.reload
      concept.origin = sprintf("_%08d", concept.id)
      concept.save! # On exception the complete save transaction will be rolled back
    end
  end

  # ********** "Static"/unconfigureable relations

  @nested_relations = [] # Will be marked as nested attributes later

  has_many :relations, :foreign_key => 'owner_id', :class_name => "Concept::Relation::Base", :dependent => :destroy
  has_many :related_concepts, :through => :relations, :source => :target
  has_many :referenced_relations, :foreign_key => 'target_id', :class_name => "Concept::Relation::Base", :dependent => :destroy
  include_to_deep_cloning(:relations, :referenced_relations)

  has_many :labelings, :foreign_key => 'owner_id', :class_name => "Labeling::Base", :dependent => :destroy
  has_many :labels, :through => :labelings, :source => :target
  # Deep cloning has to be done in specific relations. S. pref_labels etc

  has_many :notes, :class_name => "Note::Base", :as => :owner, :dependent => :destroy
  include_to_deep_cloning({:notes => :annotations})

  has_many :matches, :foreign_key => 'concept_id', :class_name => "Match::Base", :dependent => :destroy
  include_to_deep_cloning(:matches)

  has_many :collection_members, :foreign_key => 'target_id', :class_name => "Collection::Member::Base", :dependent => :destroy
  has_many :collections, :through => :collection_members, :class_name => Iqvoc::Collection.base_class_name
  include_to_deep_cloning(:collection_members)

  has_many :notations, :class_name => 'Notation::Base', :foreign_key => 'concept_id', :dependent => :destroy
  include_to_deep_cloning :notations
  @nested_relations << :notations

  # ************** "Dynamic"/configureable relations

  # *** Concept2Concept relations

  # Broader
  # FIXME: Actually this is not needed anymore.
  # BUT: the include in scope :tops doesn't work with
  # 'Iqvoc::Concept.broader_relation_class_name'!?!?! (Rails Bug????)
  has_many :broader_relations,
    :foreign_key => :owner_id,
    :class_name => Iqvoc::Concept.broader_relation_class_name,
    :extend => Concept::Relation::ReverseRelationExtension

  # Narrower
  # FIXME: Actually this is not needed anymore.
  # BUT: the include in scope :tops doesn't work with
  # 'Iqvoc::Concept.broader_relation_class_name'!?!?! (Rails Bug????)
  has_many :narrower_relations,
    :foreign_key => :owner_id,
    :class_name => Iqvoc::Concept.broader_relation_class.narrower_class.name,
    :extend => Concept::Relation::ReverseRelationExtension

  # Relations
  # e.g. 'concept_relation_skos_relateds'
  # Attention: Iqvoc::Concept.relation_class_names loads the Concept::Relation::*
  # classes!
  Iqvoc::Concept.relation_class_names.each do |relation_class_name|
    has_many relation_class_name.to_relation_name,
      :foreign_key => :owner_id,
      :class_name  => relation_class_name,
      :extend => Concept::Relation::ReverseRelationExtension
  end

  # *** Labels/Labelings

  has_many :pref_labelings,
    :foreign_key => 'owner_id',
    :class_name => Iqvoc::Concept.pref_labeling_class_name

  has_many :pref_labels,
    :through => :pref_labelings,
    :source => :target

  Iqvoc::Concept.labeling_class_names.each do |labeling_class_name, languages|
    has_many labeling_class_name.to_relation_name,
      :foreign_key => 'owner_id',
      :class_name => labeling_class_name
    # Only clone superclass relations
    unless Iqvoc::Concept.labeling_classes.keys.detect { |klass| labeling_class_name.constantize < klass }
      # When a Label has only one labeling (the "no skosxl" case) we'll have to
      # clone the label too.
      if labeling_class_name.constantize.reflections[:target].options[:dependent] == :destroy
        include_to_deep_cloning(labeling_class_name.to_relation_name => :target)
      else
        include_to_deep_cloning(labeling_class_name.to_relation_name)
      end
    end
  end

  # *** Matches (pointing to an other thesaurus)

  Iqvoc::Concept.match_class_names.each do |match_class_name|
    has_many match_class_name.to_relation_name,
      :class_name  => match_class_name,
      :foreign_key => 'concept_id'

    # Serialized setters and getters (\r\n or , separated) -- TODO: use Iqvoc::InlineDataHelper?
    define_method("inline_#{match_class_name.to_relation_name}".to_sym) do
      self.send(match_class_name.to_relation_name).map(&:value).join(Iqvoc::InlineDataHelper::JOINER)
    end

    define_method("inline_#{match_class_name.to_relation_name}=".to_sym) do |value|
      urls = value.split(Iqvoc::InlineDataHelper::SPLITTER).map(&:strip).reject(&:blank?)
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

  # *** Notes

  Iqvoc::Concept.note_class_names.each do |class_name|
    relation_name = class_name.to_relation_name
    has_many relation_name, :class_name => class_name, :as => :owner
    @nested_relations << relation_name
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
    includes(:narrower_relations, :pref_labels).
    where(:concept_relations => { :id => nil },
      :labelings => { :type => Iqvoc::Concept.pref_labeling_class_name }).
    order("LOWER(#{Label::Base.table_name}.value)")
  end

  def self.with_associations
    includes([
      { :labelings => :target }, :relations, :matches, :notes, :notations
    ])
  end

  def self.with_pref_labels
    includes(:pref_labels).
    order("LOWER(#{Label::Base.table_name}.value)").
    where(:labelings => { :type => Iqvoc::Concept.pref_labeling_class_name }) # This line is just a workaround for a Rails Bug. TODO: Delete it when the Bug is fixed
  end

  def self.for_dashboard
    unpublished_or_follow_up.includes(:pref_labels, :locking_user)
  end

  # ********** Class methods

  def self.inline_partial_name
    "partials/concept/inline_base"
  end

  def self.new_link_partial_name
    "partials/concept/new_link_base"
  end

  def self.edit_link_partial_name
    "partials/concept/edit_link_base"
  end

  # ********** Methods

  def labelings_by_text=(hash)
    @labelings_by_text = hash

    @labelings_by_text.each do |relation_name, labels_by_lang|
      # if `language` is `nil`, the respective HTML form field returns an array
      # instead of a hash (`<input name=bla[labeling_class][]>`)
      if labels_by_lang.is_a?(Array)
        @labelings_by_text[relation_name] = { nil => labels_by_lang.first }
      end
    end

    @labelings_by_text
  end

  def labelings_by_text(relation_name, language)
    (@labelings_by_text && @labelings_by_text[relation_name] &&
        @labelings_by_text[relation_name][language]) ||
        Iqvoc::InlineDataHelper.generate_inline_values(self.send(relation_name).
            by_label_language(language).map { |l| l.target.value })
  end

  def concept_relations_by_id=(hash)
    @concept_relations_by_id = hash
  end

  def concept_relations_by_id(relation_name)
    (@concept_relations_by_id && @concept_relations_by_id[relation_name]) ||
      self.send(relation_name).map { |l| l.target.origin }.
      join(Iqvoc::InlineDataHelper::JOINER)
  end

  def concept_relations_by_id_and_rank(relation_name)
    self.send(relation_name).each_with_object({}) { |rel, hsh| hsh[rel.target] = rel.rank }
    # self.send(relation_name).map { |l| "#{l.target.origin}:#{l.rank}" }
  end

  # returns the (one!) preferred label of a concept for the requested language.
  # lang can either be a (lowercase) string or symbol with the (ISO ....) two letter
  # code of the language (e.g. :en for English, :fr for French, :de for German).
  # If no prefLabel for the requested language exists, a new label will be returned
  # (if you modify it, don't forget to save it afterwards!)
  def pref_label
    lang = I18n.locale.to_s == "none" ? nil : I18n.locale.to_s
    @cached_pref_labels ||= pref_labels.each_with_object({}) do |label, hash|
      if hash[label.language]
        Rails.logger.warn("Two pref_labels (#{hash[label.language]}, #{label}) for one language (#{label.language}). Taking the second one.")
      end
      hash[label.language] = label
    end
    if @cached_pref_labels[lang].nil?
      # Fallback to the main language
      @cached_pref_labels[lang] = pref_labels.select{ |l|
          l.language.to_s == Iqvoc::Concept.pref_labeling_languages.first.to_s
      }.first
    end
    @cached_pref_labels[lang]
  end

  def labels_for_labeling_class_and_language(labeling_class, lang = :en, only_published = true)
    # Convert lang to string in case it's not nil.
    # nil values play their own role for labels without a language.
    if lang == "none"
      lang = nil
    elsif lang
      lang = lang.to_s
    end
    labeling_class = labeling_class.name if labeling_class < ActiveRecord::Base # Use the class name string
    @labels ||= labelings.each_with_object({}) do |labeling, hash|
      ((hash[labeling.class.name.to_s] ||= {})[labeling.target.language] ||= []) << labeling.target if labeling.target
    end
    ((@labels && @labels[labeling_class] && @labels[labeling_class][lang]) || []).select{|l| l.published? || !only_published}
  end

  def related_concepts_for_relation_class(relation_class, only_published = true)
    relation_class = relation_class.name if relation_class < ActiveRecord::Base # Use the class name string
    relations.select { |rel| rel.class.name == relation_class }.map(&:target).
        select { |c| c.published? || !only_published }
  end

  def matches_for_class(match_class)
    match_class = match_class.name if match_class < ActiveRecord::Base # Use the class name string
    matches.select{ |match| match.class.name == match_class }
  end

  def notes_for_class(note_class)
    note_class = note_class.name if note_class < ActiveRecord::Base # Use the class name string
    notes.select{ |note| note.class.name == note_class }
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

  def associated_objects_in_editing_mode
    {
      :concept_relations => Concept::Relation::Base.by_owner(id).target_in_edit_mode,
    }
  end

end
