class Concept::Base < ActiveRecord::Base

  set_table_name 'concepts'

  include IqvocGlobal::Versioning

  # ********** Validations

  validates :origin, :presence => true
  validate :two_versions_exist,   :on => :create
  validate :pref_label_existence, :on => :update
  # FIXME
  # validates :associations_must_be_published

  # ********** Hooks

  # ********** "Static"/unconfigureable relations

  @nested_relations = [] # Will be marked as nested attributes later

  has_many :relations, :foreign_key => 'owner_id', :class_name => "Concept::Relation::Base", :dependent => :destroy
  has_many :related_concepts, :through => :relations, :source => :target
  has_many :referenced_relations, :foreign_key => 'target_id', :class_name => "Concept::Relation::Base", :dependent => :destroy
  include_to_deep_cloning(:relations, :referenced_relations)

  has_many :labelings, :foreign_key => 'owner_id', :class_name => "Labeling::Base", :dependent => :destroy
  has_many :labels, :through => :labelings, :source => :target
  include_to_deep_cloning(:labelings)

  has_many :notes, :class_name => "Note::Base", :as => :owner, :dependent => :destroy
  has_many :iqvoc_change_notes, :class_name => Note::Iqvoc::ChangeNote, :as => :owner
  include_to_deep_cloning({:notes => :annotations})

  has_many :matches, :foreign_key => 'concept_id', :class_name => "Match::Base", :dependent => :destroy
  include_to_deep_cloning(:matches)

  # *** Classifications
  # FIXME: Should be a matches (to other skos vocabularies)
  has_many :classifications, :foreign_key => 'owner_id', :dependent => :destroy
  has_many :classifiers, :through => :classifications, :source => :target
  include_to_deep_cloning(:classifications)

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

  Iqvoc::Concept.labeling_class_names.keys.each do |labeling_class_name|
    has_many labeling_class_name.to_relation_name,
      :foreign_key => 'owner_id',
      :class_name => labeling_class_name
  end

  # *** Matches (pointing to an other thesaurus)
  Iqvoc::Concept.match_class_names.each do |match_class_name|
    has_many match_class_name.to_relation_name,
      :class_name  => match_class_name,
      :foreign_key => 'concept_id'
    @nested_relations << match_class_name.to_relation_name
  end

  # *** Notes

  Iqvoc::Concept.note_class_names.each do |class_name|
    relation_name = class_name.to_relation_name
    has_many relation_name, :class_name => class_name, :as => :owner
    @nested_relations << relation_name
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
    order("LOWER(#{Label::Base.arel_table[:value].to_sql})")

  scope :with_associations, includes([
      {:labelings => :target}, :relations, :matches, :notes
    ])

  scope :with_pref_labels,
    includes(:pref_labels).
    order("LOWER(#{Label::Base.arel_table[:value].to_sql})").
    where(:labelings => {:type => Iqvoc::Concept.pref_labeling_class_name}) # This line is just a workaround for a Rails Bug. TODO: Delete it when the Bug is fixed

  # ********** Methods

  def initialize(params = {})
    super(params)
    @full_validation = false
  end

  def labelings_by_text=(hash)
    # hash = {'relation_name' => {'lang' => 'label1, label2, ...'}}
    hash.each do |relation_name, lang_values|
      reflection = self.class.reflections.stringify_keys[relation_name]
      labeling_class = reflection && reflection.class_name && reflection.class_name.constantize
      if labeling_class && labeling_class < Labeling::Base && labeling_class.nested_editable?
        self.send(relation_name).all.map(&:destroy)
        lang_values.each do |lang, values|
          values.split(",").each do |value|
            value.squish!
            self.send(relation_name) << labeling_class.new(:target => labeling_class.label_class.new(:value => value, :language => lang)) unless value.blank?
          end
        end
      end
    end
  end

  # returns the (one!) preferred label of a concept for the requested language.
  # lang can either be a (lowercase) string or symbol with the (ISO ....) two letter
  # code of the language (e.g. :en for English, :fr for French, :de for German).
  # if lang is NIL, the current I18n language will be used will be used. If no prefLabel for the requested language exists,
  # a new label will be returned (if you modify it, don't forget to save it afterwards!)
  def pref_label(lang = nil)
    lang ||= I18n.locale
    lang = lang.to_s
    @cached_pref_labels ||= pref_labels.each_with_object({}) do |label, hash|
      Rails.logger.warn("Two pref_labels (#{hash[label.language]}, #{label}) for one language (#{label.language}). Taking the second one.") if hash[label.language]
      hash[label.language] = label
    end
    if @cached_pref_labels[lang].nil?
      @cached_pref_labels[lang] = Iqvoc::Concept.pref_labeling_class.label_class.new(:language => lang, :value => "(#{self.origin})")
      @cached_pref_labels[lang].concepts << self
    end
    @cached_pref_labels[lang]
  end

  def labels_for_labeling_class_and_language(labeling_class, lang = :en, only_published = true)
    labeling_class = labeling_class.name if labeling_class < ActiveRecord::Base # Use the class name string
    @labels ||= labelings.each_with_object({}) do |labeling, hash|
      ((hash[labeling.class.name.to_s] ||= {})[labeling.target.language] ||= []) << labeling.target
    end
    return ((@labels && @labels[labeling_class] && @labels[labeling_class][lang.to_s]) || []).select{|l| l.published? || !only_published}
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

  # this find_by_origin method returns only instances of the current class.
  # The dynamic find_by... method would have considered ALL (sub)classes (STI)
  def self.find_by_origin(origin)
    find(:first, :conditions => ["concepts.origin=? AND concepts.type=?", origin, self.to_s])
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
    concept = Concept::Base.select(:origin).order("origin DESC").first
    value   = concept.blank? ? 1 : concept.origin.to_i + 1
    write_attribute(:origin, sprintf("_%08d", value))
  end

  def associated_objects_in_editing_mode
    {
      :concept_relations => Concept::Relation::Base.by_owner(id).target_in_edit_mode,
      :labelings         => Labeling::SKOSXL::Base.by_concept(self).target_in_edit_mode
    }
  end
    
  protected
  
  def two_versions_exist
    errors.add(:base, I18n.t("txt.models.concept.version_error")) if Concept::Base.by_origin(origin).count >= 2
  end

  def pref_label_existence
    if @full_validation == true
      errors.add(:base, I18n.t("txt.models.concept.pref_label_error")) if pref_labels.count == 0
    end
  end
  
  def associations_must_be_published
    if @full_validation == true
      [:labels, :related_concepts].each do |method|
        if self.send(method).unpublished.any?
          errors[:base] << I18n.t("txt.models.concept.association_#{method}_unpublished")
        end
      end
    end
  end
end
