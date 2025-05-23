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

class Concept::Base < ApplicationRecord
  attr_accessor :reverse_match_service
  self.table_name = 'concepts'

  class_attribute :default_includes
  self.default_includes = []

  class_attribute :rdf_namespace, :rdf_class
  self.rdf_namespace = nil
  self.rdf_class = nil

  Iqvoc::Concept.include_modules.each do |mod|
    include mod
  end

  include Versioning
  include Concept::Validations
  include FirstLevelObjectValidations
  include FirstLevelObjectScopes
  include Expirable

  # ********** Hooks

  after_initialize do |concept|
    if concept.origin.blank?
      concept.origin = Origin.new.to_s
    end
  end

  before_validation do |concept|
    # Handle save or destruction of inline relations (relations or labelings)
    # for use with widgets etc.

    # Inline assigned Skos::Labels
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
          InlineDataHelper.parse_inline_values(inline_values).each do |value|
            value.squish!
            unless value.blank?
              self.send(relation_name).build(target: labeling_class.label_class.new(value: value, language: lang))
            end
          end
        end
      end
    end
  end

  after_save do |concept|
    # Generate a origin if none was given yet
    if concept.origin.blank?
      raise 'Concept::Base#after_save (generate origin): Unable to set the origin by id!' unless concept.id
      concept.reload
      concept.origin = sprintf('_%08d', concept.id)
      concept.save! # On exception the complete save transaction will be rolled back
    end

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
      new_origins = new_origins.split(InlineDataHelper::SPLITTER).map(&:squish)

      # Extract embedded ranks (if any) from origin strings (e.g. "origin1:100")
      # => { 'origin1' => nil, 'origin2' => 90 }
      new_origins = new_origins.each_with_object({}) do |e, hsh|
        key, value = e.split(':') # NB: defaults to nil if no rank is provided
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
        concept.send(relation_name).create_with_reverse_relation(c, rank: new_origins[c.origin])
      end
    end

    # Process assigned collections
    if @assigned_collection_origins
      transaction do
        collections.destroy_all

        # Rebuild collection relations
        @assigned_collection_origins.each do |origin|
          collection = Iqvoc::Collection.base_class.by_origin(origin).published.first
          if collection
            Iqvoc::Collection.member_class.create! do |m|
              m.collection = collection
              m.target = concept
            end
          end
        end
      end
    end

    if (@inline_matches ||= {}).any?
      @inline_matches.each do |match_class, urls|
        # temp array to check existing match-urls
        # we cannot use @inline_matches (call by reference)
        urls_copy = urls.dup

        # destroy old relations
        self.send(match_class.to_relation_name).each do |match|
          if (urls_copy.include?(match.value))
            urls_copy.delete(match.value) # We're done with that one
          else
            self.send(match_class.to_relation_name).destroy(match.id) # User deleted this one

            if self.reverse_match_service.present? && federation_match?(match.value)
              job = self.reverse_match_service.build_job(:remove_match, self, match.value, match_class)
              self.reverse_match_service.add(job)
            end

          end
        end

        # create new match relations
        urls_copy.each do |url|
          self.send(match_class.to_relation_name) << match_class.constantize.new(value: url)

          if self.reverse_match_service.present? && federation_match?(url)
            job = self.reverse_match_service.build_job(:add_match, self, url, match_class)
            self.reverse_match_service.add(job)
          end

        end
      end
    end

  end

  # ********** "Static"/unconfigureable relations

  @nested_relations = [] # Will be marked as nested attributes later

  has_many :relations,
           foreign_key: 'owner_id',
           class_name: 'Concept::Relation::Base',
           dependent: :destroy,
           inverse_of: :owner

  has_many :related_concepts,
           through: :relations,
           source: :target

  has_many :referenced_relations,
           foreign_key: 'target_id',
           class_name: 'Concept::Relation::Base',
           dependent: :destroy,
           inverse_of: :target
  include_to_deep_cloning(:relations, :referenced_relations)

  has_many :labelings,
           foreign_key: 'owner_id',
           class_name: 'Labeling::Base',
           dependent: :destroy,
           inverse_of: :owner

  has_many :labels, -> { order(:value) },
           through: :labelings,
           source: :target
  # Deep cloning has to be done in specific relations. S. pref_labels etc

  has_many :notes,
           class_name: 'Note::Base',
           as: :owner,
           dependent: :destroy,
           inverse_of: :owner
  include_to_deep_cloning({ notes: :annotations })

  has_many :matches,
           foreign_key: 'concept_id',
           class_name: 'Match::Base',
           dependent: :destroy,
           inverse_of: :concept
  include_to_deep_cloning(:matches)

  has_many :collection_members,
           foreign_key: 'target_id',
           class_name: 'Collection::Member::Base',
           dependent: :destroy,
           inverse_of: :target

  has_many :collections,
           through: :collection_members,
           class_name: Iqvoc::Collection.base_class_name
  include_to_deep_cloning(:collection_members)

  has_many :notations,
           class_name: 'Notation::Base',
           foreign_key: 'concept_id',
           dependent: :destroy,
           inverse_of: :concept
  include_to_deep_cloning :notations

  @nested_relations << :notations

  # ************** "Dynamic"/configureable relations

  # *** Concept2Concept relations

  # Broader
  # FIXME: Actually this is not needed anymore.
  # BUT: the include in scope :tops doesn't work with
  # 'Iqvoc::Concept.broader_relation_class_name'!?!?! (Rails Bug????)
  has_many :broader_relations,
    foreign_key: :owner_id,
    class_name: Iqvoc::Concept.broader_relation_class_name,
    extend: Concept::Relation::ReverseRelationExtension,
    inverse_of: :owner

  # Narrower
  # FIXME: Actually this is not needed anymore.
  # BUT: the include in scope :tops doesn't work with
  # 'Iqvoc::Concept.broader_relation_class_name'!?!?! (Rails Bug????)
  has_many :narrower_relations,
    foreign_key: :owner_id,
    class_name: Iqvoc::Concept.broader_relation_class.narrower_class.name,
    extend: Concept::Relation::ReverseRelationExtension,
    inverse_of: :owner

  # Relations
  # e.g. 'concept_relation_skos_relateds'
  # Attention: Iqvoc::Concept.relation_class_names loads the Concept::Relation::*
  # classes!
  Iqvoc::Concept.relation_class_names.each do |relation_class_name|
    has_many relation_class_name.to_relation_name,
      foreign_key: :owner_id,
      class_name: relation_class_name,
      extend: Concept::Relation::ReverseRelationExtension,
      inverse_of: :owner
  end

  # *** Labels/Labelings

  has_many :pref_labelings,
    foreign_key: 'owner_id',
    class_name: Iqvoc::Concept.pref_labeling_class_name,
    inverse_of: :owner

  has_many :pref_labels,
    -> { order(:value) },
    through: :pref_labelings,
    source: :target

  has_many :alt_labelings,
    foreign_key: 'owner_id',
    class_name: Iqvoc::Concept.alt_labeling_class_name,
    inverse_of: :owner

  has_many :alt_labels,
    -> { order(:value) },
    through: :alt_labelings,
    source: :target

  has_many :hidden_labelings,
           foreign_key: 'owner_id',
           class_name: Iqvoc::Concept.hidden_labeling_class_name,
           inverse_of: :owner

  has_many :hidden_labels,
           -> { order(:value) },
           through: :hidden_labelings,
           source: :target

  Iqvoc::Concept.labeling_class_names.each do |labeling_class_name, languages|
    has_many labeling_class_name.to_relation_name,
      foreign_key: 'owner_id',
      class_name: labeling_class_name,
      inverse_of: :owner

    # Only clone superclass relations
    unless Iqvoc::Concept.labeling_classes.keys.detect { |klass| labeling_class_name.constantize < klass }
      # When a Label has only one labeling (the "no skosxl" case) we'll have to
      # clone the label too.
      if labeling_class_name.constantize.reflections['target'].options[:dependent] == :destroy
        include_to_deep_cloning(labeling_class_name.to_relation_name => :target)
      else
        include_to_deep_cloning(labeling_class_name.to_relation_name)
      end
    end
  end

  # *** Matches (pointing to an other thesaurus)

  Iqvoc::Concept.match_class_names.each do |match_class_name|
    has_many match_class_name.to_relation_name,
      class_name: match_class_name,
      foreign_key: 'concept_id',
      inverse_of: :concept

    # Serialized setters and getters (\r\n or , separated) -- TODO: use InlineDataHelper?
    define_method("inline_#{match_class_name.to_relation_name}".to_sym) do
      self.send(match_class_name.to_relation_name).map(&:value).join(InlineDataHelper::JOINER)
    end

    define_method("inline_#{match_class_name.to_relation_name}=".to_sym) do |value|
      urls = value.split(InlineDataHelper::SPLITTER).map(&:strip).reject(&:blank?)
      @inline_matches ||= {}
      @inline_matches[match_class_name] = urls
    end

  end

  # *** Notes

  Iqvoc::Concept.note_class_names.each do |class_name|
    relation_name = class_name.to_relation_name
    has_many relation_name,
             class_name: class_name,
             as: :owner,
             inverse_of: :owner
    @nested_relations << relation_name
  end

  # *** Further association classes (could be ranks or stuff like that)

  Iqvoc::Concept.additional_association_classes.each do |association_class, foreign_key|
    has_many association_class.name.to_relation_name,
             class_name: association_class.name,
             foreign_key: foreign_key,
             dependent: :destroy # TODO: add inverse_of???
    include_to_deep_cloning(association_class.deep_cloning_relations)
    association_class.referenced_by(self)
  end

  # ********** Relation Stuff

  @nested_relations.each do |relation|
    accepts_nested_attributes_for relation, allow_destroy: true, reject_if: Proc.new { |attrs| attrs[:value].blank? }
  end

  # ********** Scopes

  def self.tops
    where(top_term: true)
  end

  def self.broader_tops
    includes(:narrower_relations, :pref_labels).
    where(concept_relations: { id: nil },
      labelings: { type: Iqvoc::Concept.pref_labeling_class_name }).
    order(Arel.sql("LOWER(#{Label::Base.table_name}.value)"))
  end

  def self.with_associations
    includes([
      { labelings: :target }, :relations, :matches, :notes, :notations
    ])
  end

  def self.with_pref_labels
    preload(:pref_labels)
      .joins(:pref_labels)
      .order(Arel.sql("LOWER(#{Label::Base.table_name}.value)"))
  end

  def self.for_dashboard
    unpublished_or_follow_up.includes(:pref_labels)
  end

  def self.parentless
    includes(:broader_relations)
      .where(concept_relations: {owner_id: nil}, top_term: false)
      .references(:concept_relations)
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

  def self.dashboard_path
    'dashboard_path'
  end

  # ********** Methods

  def class_path
    'concept_path'
  end

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
        InlineDataHelper.generate_inline_values(self.send(relation_name).
            by_label_language(language).map { |l| l.target.value })
  end

  def concept_relations_by_id=(hash)
    @concept_relations_by_id = hash
  end

  def concept_relations_by_id(relation_name)
    (@concept_relations_by_id && @concept_relations_by_id[relation_name]) ||
      self.send(relation_name).map { |l| l.target.origin }.
      join(InlineDataHelper::JOINER)
  end

  def concept_relations_by_id_and_rank(relation_name)
    self.send(relation_name).each_with_object({}) { |rel, hsh| hsh[rel.target] = rel.rank }
    # self.send(relation_name).map { |l| "#{l.target.origin}:#{l.rank}" }
  end

  def assigned_collection_origins=(origins)
    @assigned_collection_origins= origins.to_s
      .split(InlineDataHelper::SPLITTER).map(&:strip)
  end

  def assigned_collection_origins
    @assigned_collection_origins || collections.map(&:origin).uniq
  end

  # returns the (one!) preferred label of a concept for the requested language.
  # lang can either be a (lowercase) string or symbol with the (ISO ....) two letter
  # code of the language (e.g. :en for English, :fr for French, :de for German).
  # If no prefLabel for the requested language exists, a new label will be returned
  # (if you modify it, don't forget to save it afterwards!)
  def pref_label
    if pref_labels.loaded?
      # use select if association is already loaded
      @cached_pref_labels ||= pref_labels.select(&:published?).each_with_object({}) do |label, hash|
        if hash[label.language]
          Rails.logger.warn("Two pref_labels (#{hash[label.language]}, #{label}) for one language (#{label.language}). Taking the second one.")
        end
        hash[label.language] = label
      end
    else
      # use scope otherwise
      @cached_pref_labels ||= pref_labels.published.each_with_object({}) do |label, hash|
        if hash[label.language]
          Rails.logger.warn("Two pref_labels (#{hash[label.language]}, #{label}) for one language (#{label.language}). Taking the second one.")
        end
        hash[label.language] = label
      end
    end

    lang = I18n.locale.to_s == 'none' ? nil : I18n.locale.to_s

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
    if lang == 'none'
      lang = nil
    elsif lang
      lang = lang.to_s
    end
    labeling_class = labeling_class.name if labeling_class < ApplicationRecord # Use the class name string
    @labels ||= labelings.each_with_object({}) do |labeling, hash|
      ((hash[labeling.class.name.to_s] ||= {})[labeling.target.language] ||= []) << labeling.target if labeling.target
    end
    ((@labels && @labels[labeling_class] && @labels[labeling_class][lang]) || []).select{ |l| l.published? || !only_published }
  end

  def related_concepts_for_relation_class(relation_class, only_published = true)
    relation_class = relation_class.name if relation_class < ApplicationRecord # Use the class name string
    relations.select { |rel| rel.class.name == relation_class }.map(&:target).
        select { |c| c.published? || !only_published }.sort_by(&:pref_label)
  end

  def matches_for_class(match_class)
    match_class = match_class.name if match_class < ApplicationRecord # Use the class name string
    matches.select{ |match| match.class.name == match_class }
  end

  def notes_for_class(note_class)
    note_class = note_class.name if note_class < ApplicationRecord # Use the class name string
    notes.select{ |note| note.class.name == note_class }
  end

  def notations_for_class(notation_class)
    notation_class = notation_class.name if notation_class < ApplicationRecord # Use the class name string
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
      concept_relations: Concept::Relation::Base.by_owner(id).target_in_edit_mode,
    }
  end

  def jobs
    gid = self.to_global_id.to_s
    Delayed::Backend::ActiveRecord::Job.where(delayed_global_reference_id: gid)
  end

  def expired?
    self.expired_at && self.expired_at <= Date.today
  end

  private

  # checks if provided uri is defined as a federation source
  # e.g:
  # iqvoc_sources = ['http://example.org']
  # http://www.google.com       => false
  # http://www.example.org/1234 => true
  def federation_match?(url)
    result = false

    iqvoc_sources = Iqvoc.config['sources.iqvoc'].map{ |url| URI.parse(url) }
    url_object = URI.parse(url)

    # check if uri is part of one iqvoc sources
    iqvoc_sources.each do |source|
      # check if base part of the url is defined as a federation source
      if source.host == url_object.host && source.port == url_object.port
        result = true
        break # match found, stop iterating
      end
    end

    result
  end

end
