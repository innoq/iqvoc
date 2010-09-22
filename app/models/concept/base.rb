class Concept::Base < ActiveRecord::Base

  set_table_name 'concepts'

  include IqvocGlobal::CommonScopes
  include IqvocGlobal::CommonMethods
  include IqvocGlobal::CommonAssociations
  include IqvocGlobal::ConceptAssociationExtensions
  
  # ********** Validations

  validate :origin, :presence => true
  validate :two_versions_exist, :on => :create
  validate :pref_label_existence, :associations_must_be_published, :on => :update

  # ********** Hooks

  before_destroy :has_references?

  # ********** "Static"/unconfigureable relations

  @nested_relations = [] # Will be marked as nested attributes later

  has_many :relations, :foreign_key => 'owner_id', :class_name => "Concept::Relation::Base"
  has_many :related_concepts, :through => :relations, :source => :target

  has_many :labelings, :foreign_key => 'owner_id', :class_name => "Labeling::Base"
  has_many :labels, :through => :labelings, :source => :target

  has_many :notes, :class_name => "Note::Base", :as => :owner
  has_many :iqvoc_change_notes, :class_name => Note::Iqvoc::ChangeNote, :as => :owner

  has_many :matches, :foreign_key => 'concept_id', :class_name => "Match::Base"

  # *** Classifications
  # FIXME: Should be a matches (to other skos vocabularies)
  has_many :classifications, :foreign_key => 'owner_id'
  has_many :classifiers, :through => :classifications, :source => :target
  
  # FIXME: What is this for?
  has_many :referenced_matches,           :class_name => "Match::Base",       :foreign_key => 'value'
  has_many :referenced_concept_relations, :class_name => "Concept::Relation::Base", :foreign_key => 'target_id'

  # ************** "Dynamic"/configureable relations

  # *** Concept2Concept relations

  # Broader
  has_many :broader_relations,
    :foreign_key => :owner_id,
    :class_name => Iqvoc::Concept.broader_relation_class_name,
    :extend => [ PushWithReflectionExtension, DestroyReflectionExtension ] # FIXME: This must be understood and refactored!!!!
  has_many :broader,
    :through => :broader_relations,
    :source => :target

  # Narrower
  has_many :narrower_relations,
    :foreign_key => :owner_id,
    :class_name => 'Concept::Relation::SKOS::Narrower', # FIXME: Must this be configureable????s
  :extend => [ PushWithReflectionExtension, DestroyReflectionExtension ] # FIXME: This must be understood and refactored!!!!
  has_many :narrower,
    :through => :narrower_relations,
    :source => :target

  # Further relations
  # e.g. 'concept_relation_skos_relateds'
  Iqvoc::Concept.further_relation_class_names.each do |relation_class_name|
    has_many relation_class_name.to_relation_name,
      :foreign_key => :owner_id,
      :class_name  => relation_class_name,
      :extend => [ PushWithReflectionExtension, DestroyReflectionExtension ] # FIXME: This must be understood and refactored!!!!
  end

  # *** Labels/Labelings

  has_many :pref_labelings,
    :foreign_key => 'owner_id',
    :class_name => Iqvoc::Concept.pref_labeling_class_name
  has_many :pref_labels,
    :through => :pref_labelings,
    :source => :target

  Iqvoc::Concept.further_labeling_class_names.keys.each do |labeling_class_name|
    has_many labeling_class_name.to_relation_name,
      :foreign_key => 'owner_id',
      :class_name => labeling_class_name
  end

  # *** Matches (pointing to an other thesaurus)
  Iqvoc::Concept.match_class_names.each do |match_class_name|
    has_many match_class_name.to_relation_name, :class_name => match_class_name
    @nested_relations << match_class_name.to_relation_name
  end

  # *** Notes

  Iqvoc::Concept.note_class_names.each do |class_name|
    relation_name = class_name.to_relation_name
    has_many relation_name, :class_name => class_name, :as => :owner
    @nested_relations << relation_name
  end

  # ********** Relation Stuff

  # FIXME
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
    order('LOWER(labels.value)')

  scope :with_associations, includes([
      {:labelings => :target}, :relations, :matches, :notes
    ])

  scope :with_pref_labels,
    includes(:pref_labels).
    order("LOWER(#{Label::Base.table_name}.value)").
    where(:labelings => {:type => Iqvoc::Concept.pref_labeling_class_name}) # This line is just a workaround for a Rails Bug. TODO: Delete it when the Bug is fixed

  scope :in_edit_mode,
    where(arel_table[:locked_by].eq(nil).complement)

  def self.associations_for_versioning
    [ 
      :labelings, 
      :relations, 
      :referenced_concept_relations, 
      :matches, 
      :referenced_matches, 
      :classifications, 
      {:notes => :annotations}
    ]
  end

  def self.first_level_associations
    [
      :labelings, 
      :relations, 
      :referenced_concept_relations, 
      :referenced_matches, 
      :matches, 
      :classifications, 
      :notes
    ]
  end

  # ********** Methods

  def initialize(params = {})
    super(params)
    @full_validation = false
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
    return @cached_pref_labels[lang] if @cached_pref_labels[lang]
    pref_label = Iqvoc::Concept.pref_labeling_class.label_class.new(:language => lang)
    pref_label.concepts << self
    pref_label
  end

  def labels_for_labeling_class_and_language(labeling_class, lang = :en)
    labeling_class = labeling_class.name if labeling_class < ActiveRecord::Base # Use the class name string
    @labels ||= labelings.each_with_object({}) do |labeling, hash|
      ((hash[labeling.class.name.to_s] ||= {})[labeling.target.language] ||= []) << labeling.target
    end
    return (@labels && @labels[labeling_class] && @labels[labeling_class][lang.to_s]) || []
  end

  def related_concepts_for_relation_class(relation_class)
    relation_class = relation_class.name if relation_class < ActiveRecord::Base # Use the class name string
    relations.select{ |rel| rel.class.name == relation_class }.map(&:target)
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

  def collect_first_level_associated_objects
    associated_objects = Array.new
    Concept.first_level_associations.each do |association|
      associated_objects << self.send(association)
    end
    associated_objects.flatten
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
    concept = Concept.select(:origin).order("origin DESC").first
    value   = concept.blank? ? 1 : concept.origin.to_i + 1
    write_attribute(:origin, sprintf("_%08d", value))
  end

  def associated_objects_in_editing_mode
    { 
      :concept_relations => Concept::Relation::Base.target_in_edit_mode(id), 
      :labelings         => Labeling::SKOSXL::Base.target_in_edit_mode(id)
    }
  end
    
  def rdf_uri(opts = {})
    "#{Rails.application.config.rdf_data_uri_prefix}#{origin}#{(opts[:format] ? "?format=#{CGI.escape(opts[:format].to_s)}" : "")}"
  end

  protected
  
  def two_versions_exist
    errors.add(:base, I18n.t("txt.models.concept.version_error")) if self.by_origin(self.origin).size >= 2
  end

  def has_references?
    if (self.referenced_matches.size != 0) || (self.referenced_semantic_relations.size != 0)
      false
    else
      true
    end
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
          errors.add(:base, I18n.t("txt.models.concept.association_#{method}_unpublished"))
        end
      end
    end
  end
end
