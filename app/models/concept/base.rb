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

  set_table_name 'concepts'

  include Iqvoc::Versioning

  class_inheritable_accessor :default_includes
  self.default_includes = []

  class_inheritable_accessor :rdf_namespace, :rdf_class
  self.rdf_namespace = nil
  self.rdf_class = nil

  # ********** Validations

  validates :origin, :presence => true

  validate :ensure_maximum_two_versions_of_a_concept,
    :on => :create

  validate :ensure_a_pref_label_in_the_primary_thesaurus_language, 
    :on => :update
    
  validate :ensure_no_pref_labels_share_the_same_language

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
        self.send(relation_name).all.map(&:destroy)
        lang_values = {nil => lang_values.first} if lang_values.is_a?(Array) # For language = nil: <input name=bla[labeling_class][]> => Results in an Array!
        lang_values.each do |lang, values|
          values.split(",").each do |value|
            value.squish!
            self.send(relation_name).build(:target => labeling_class.label_class.new(:value => value, :language => lang)) unless value.blank?
          end
        end
      end
    end

    # Concept relations
    # @concept_relations_by_id # => {'relation_name' => 'origin1, origin2, ...'}
    (@concept_relations_by_id ||= {}).each do |relation_name, new_origins|
      new_origins = new_origins.split(/[,\n]/).map(&:squish)
      existing_origins = concept.send(relation_name).map{|r| r.target.origin}.uniq
      Concept::Base.by_origin(new_origins - existing_origins).each do |c| # Iterate over all concepts to be added
        concept.send(relation_name).create_with_reverse_relation(c)
      end
      concept.send(relation_name).by_target_origin(existing_origins - new_origins).each do |relation| # Iterate over all concepts to be removed
        concept.send(relation_name).destroy_with_reverse_relation(relation.target)
      end
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

  has_many :collection_members, :foreign_key => 'target_id', :class_name => "Collection::Member::Concept", :dependent => :destroy
  has_many :collections, :through => :collection_members, :class_name => Iqvoc::Collection.base_class_name
  include_to_deep_cloning(:collection_members)

  # ************** "Dynamic"/configureable relations

  # *** Concept2Concept relations

  # Broader
  # FIXME: this is not needed anymore.
  # BUT: the include in scope :tops doesn't work with
  # 'Iqvoc::Concept.broader_relation_class_name'!?!?! (Rails Bug????)
  has_many :broader_relations,
    :foreign_key => :owner_id,
    :class_name => Iqvoc::Concept.broader_relation_class_name,
    :extend => Concept::Relation::ReverseRelationExtension

  # Narrower
  # FIXME: this is not needed anymore.
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
  # BEWARE: bla.pref_labels wont work, because a Rails bug will kill the
  # nessacary type="..." condition! FIXME
  has_many :pref_labels,
    :through => :pref_labelings,
    :source => :target


  # {
  #   "Labeling::SKOSXL::PrefLabel" => {
  #     :de => [
  #       [0] "Aal"
  #     ]
  #     },
  #     "Labeling::SKOSXL::AltLabel" => {
  #       :de => [
  #         [0] "EuropaeischerFlussaal",
  #         [1] "Flussaal"
  #       ]
  #     }
  #   }
  Iqvoc::Concept.labeling_class_names.each do |labeling_class_name, languages|
    has_many labeling_class_name.to_relation_name,
      :foreign_key => 'owner_id',
      :class_name => labeling_class_name
    # When a Label has only one labeling (the "no skosxl" case) we'll have to
    # clone the label too.
    if labeling_class_name.constantize.reflections[:target].options[:dependent] == :destroy
      include_to_deep_cloning(labeling_class_name.to_relation_name => :target)
    else
      include_to_deep_cloning(labeling_class_name.to_relation_name)
    end
  end

  # *** Matches (pointing to an other thesaurus)
  Iqvoc::Concept.match_class_names.each do |match_class_name|
    has_many match_class_name.to_relation_name,
      :class_name  => match_class_name,
      :foreign_key => 'concept_id'

    # Serialized setters and getters (\r\n or , separated)
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

  # *** Notes

  Iqvoc::Concept.note_class_names.each do |class_name|
    relation_name = class_name.to_relation_name
    has_many relation_name, :class_name => class_name, :as => :owner
    @nested_relations << relation_name
  end

  Iqvoc::Concept.additional_association_classes.each do |association_class, foreign_key|
    has_many association_class.name.to_relation_name, :class_name => association_class.name, :foreign_key => foreign_key, :dependent => :destroy
    include_to_deep_cloning(association_class.deep_cloning_relations)
    association_class.referenced_by(self)
  end

  # ********** Relation Stuff

  @nested_relations.each do |relation|
    accepts_nested_attributes_for relation, :allow_destroy => true, :reject_if => Proc.new {|attrs| attrs[:value].blank? }
  end

  # ********** Scopes

  #scope :tops,
  #  :conditions => "NOT EXISTS (SELECT DISTINCT sr.owner_id FROM  concept_relations sr WHERE sr.type = 'Broader' AND sr.owner_id = concepts.id) AND labelings.type = 'PrefLabeling'",
  #  :include => :pref_labels,
  #  :order => 'LOWER(labels.value)',
  #  :group => 'concepts.id, concepts.type, concepts.created_at, concepts.updated_at, concepts.origin, concepts.status, concepts.classified, concepts.country_code, concepts.rev, concepts.published_at, concepts.locked_by, concepts.expired_at, concepts.follow_up, labels.id, labels.created_at, labels.updated_at, labels.language, labels.value, labels.base_form, labels.inflectional_code, labels.part_of_speech, labels.status, labels.origin, labels.rev, labels.published_at, labels.locked_by, labels.expired_at, labels.follow_up, labels.endings'
  scope :tops, includes(:broader_relations).
    where(:concept_relations => {:id => nil})

  # scope :broader_tops,
  #   :conditions => "NOT EXISTS (SELECT DISTINCT sr.target_id FROM concept_relations sr WHERE sr.type = 'Narrower' AND sr.owner_id = concepts.id GROUP BY sr.target_id) AND labelings.type = 'PrefLabeling'",
  #   :include => :pref_labels,
  #   :order => 'LOWER(labels.value)',
  #   :group => 'concepts.id'
  scope :broader_tops, includes(:narrower_relations, :pref_labels).
    where(:concept_relations => {:id => nil}, :labelings => {:type => Iqvoc::Concept.pref_labeling_class_name}).
    order("LOWER(#{Label::Base.table_name}.value)")

  scope :with_associations, includes([
      {:labelings => :target}, :relations, :matches, :notes
    ])

  scope :with_pref_labels,
    includes(:pref_labels).
    order("LOWER(#{Label::Base.table_name}.value)").
    where(:labelings => {:type => Iqvoc::Concept.pref_labeling_class_name}) # This line is just a workaround for a Rails Bug. TODO: Delete it when the Bug is fixed

  # ********** Class methods

  # this find_by_origin method returns only instances of the current class.
  # The dynamic find_by... method would have considered ALL (sub)classes (STI)
  def self.find_by_origin(origin)
    find(:first, :conditions => ["concepts.origin=? AND concepts.type=?", origin, self.to_s])
  end

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
  
  def initialize(params = {})
    super(params)
    @full_validation = false
  end
  
  def labelings_by_text=(hash)
    @labelings_by_text = hash
  end

  def labelings_by_text(relation_name, language)
    (@labelings_by_text && @labelings_by_text[relation_name] && @labelings_by_text[relation_name][language]) ||
      self.send(relation_name).by_label_language(language).map{ |l| l.target.value }.join(", ")
  end
  
  def concept_relations_by_id=(hash)
    @concept_relations_by_id = hash
  end

  def concept_relations_by_id(relation_name)
    (@concept_relations_by_id && @concept_relations_by_id[relation_name]) ||
      self.send(relation_name).map{ |l| l.target.origin }.join(", ")
  end

  # returns the (one!) preferred label of a concept for the requested language.
  # lang can either be a (lowercase) string or symbol with the (ISO ....) two letter
  # code of the language (e.g. :en for English, :fr for French, :de for German).
  # If no prefLabel for the requested language exists, a new label will be returned
  # (if you modify it, don't forget to save it afterwards!)
  def pref_label
    lang = I18n.locale.to_s
    @cached_pref_labels ||= pref_labels.each_with_object({}) do |label, hash|
      if hash[label.language]
        Rails.logger.warn("Two pref_labels (#{hash[label.language]}, #{label}) for one language (#{label.language}). Taking the second one.")
      end
      hash[label.language.to_s] = label
    end
    if @cached_pref_labels[lang].nil?
      # Fallback to the main language
      @cached_pref_labels[lang] = pref_labels.by_language(Iqvoc::Concept.pref_labeling_languages.first.to_s).first
    end
    @cached_pref_labels[lang]
  end

  def labels_for_labeling_class_and_language(labeling_class, lang = :en, only_published = true)
    # Convert lang to string in case it's not nil.
    # nil values play their own role for labels without a language.
    lang = lang.to_s unless lang.nil?
    labeling_class = labeling_class.name if labeling_class < ActiveRecord::Base # Use the class name string
    @labels ||= labelings.each_with_object({}) do |labeling, hash|
      ((hash[labeling.class.name.to_s] ||= {})[labeling.target.language] ||= []) << labeling.target if labeling.target
    end
    return ((@labels && @labels[labeling_class] && @labels[labeling_class][lang]) || []).select{|l| l.published? || !only_published}
  end

  def related_concepts_for_relation_class(relation_class, only_published = true)
    relation_class = relation_class.name if relation_class < ActiveRecord::Base # Use the class name string
    relations.select{ |rel| rel.class.name == relation_class }.map(&:target).select{|c| c.published? || !only_published}
  end

  def matches_for_class(match_class)
    match_class = match_class.name if match_class < ActiveRecord::Base # Use the class name string
    matches.select{ |match| match.class.name == match_class }
  end

  def notes_for_class(note_class)
    note_class = note_class.name if note_class < ActiveRecord::Base # Use the class name string
    notes.select{ |note| note.class.name == note_class }
  end
  
  # This shows up to the left of a concept link if it doesn't return nil
  def additional_info
    nil
  end

  def to_param
    "#{origin}"
  end

  def to_s
    pref_label.to_s
  end

  def save_with_full_validation!
    @full_validation = true
    save!
  end

  def valid_with_full_validation?
    @full_validation = true
    valid?
  end

  def generate_origin
    concept = Concept::Base.select(:origin).last
    value = concept.blank? ? 1 : concept.origin.to_i + 1
    write_attribute(:origin, sprintf("_%08d", value))
  end

  def associated_objects_in_editing_mode
    {
      :concept_relations => Concept::Relation::Base.by_owner(id).target_in_edit_mode,
      # TODO: move to mixin      :labelings         => Labeling::SKOSXL::Base.by_concept(self).target_in_edit_mode
    }
  end
  
  # ********** Validation methods
  
  def ensure_maximum_two_versions_of_a_concept
    if Concept::Base.by_origin(origin).count >= 2
      errors.add :base, I18n.t("txt.models.concept.version_error")
    end
  end
  
  def ensure_a_pref_label_in_the_primary_thesaurus_language
    if @full_validation
      labels = pref_labels.select{|l| l.published?}
      if labels.count == 0
        errors.add :base, I18n.t("txt.models.concept.no_pref_label_error")
      elsif !labels.map(&:language).include?(Iqvoc::Concept.pref_labeling_languages.first.to_s)
        errors.add :base, I18n.t("txt.models.concept.main_pref_label_language_missing_error")
      end
    end
  end
  
  def ensure_no_pref_labels_share_the_same_language
    # We have many sources a prefLabel can be defined in
    pls = pref_labelings.map(&:target) +
      send(Iqvoc::Concept.pref_labeling_class_name.to_relation_name).map(&:target) +
      labelings.select{|l| l.is_a?(Iqvoc::Concept.pref_labeling_class)}.map(&:target)
    languages = {}
    pls.each do |pref_label|
      lang = pref_label.language.to_s
      origin = (pref_label.origin || pref_label.id || pref_label.value).to_s
      if (languages.keys.include?(lang) && languages[lang] != origin)
        errors.add :pref_labelings, I18n.t("txt.models.concept.pref_labels_with_same_languages_error")
      end
      languages[lang] = origin
    end
  end

end
