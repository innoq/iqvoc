class Concept::Base < ActiveRecord::Base

  set_table_name 'concepts'

  include IqvocGlobal::CommonScopes
  include IqvocGlobal::CommonMethods
  include IqvocGlobal::CommonAssociations
  include IqvocGlobal::ConceptAssociationExtensions
  
  validate :origin, :presence => true
  validate :two_versions_exist, :on => :create
  validate :pref_label_existence, :associations_must_be_published, :on => :update

  before_destroy :has_references?

  # ********** Relations
  @nested_relations = [] # Will be marked as nested attributes later

  has_many :concept_relations, :foreign_key => 'owner_id'

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
    :class_name => 'Concept::Relations::Narrower', # FIXME: Must this be configureable????
    :extend => [ PushWithReflectionExtension, DestroyReflectionExtension ] # FIXME: This must be understood and refactored!!!!
  has_many :narrower,
    :through => :broader_relations,
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
  has_many :labelings, :foreign_key => 'owner_id', :class_name => Labeling::Base.name

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

  # *** Classifications
  has_many :classifications, :foreign_key => 'owner_id'
  has_many :classifiers, :through => :classifications, :source => :target
  
  # FIXME
  has_many :umt_source_notes, :foreign_key => 'owner_id', :class_name => 'UMT::SourceNote', :conditions => { :owner_type => self.name }
  has_many :umt_usage_notes,  :foreign_key => 'owner_id', :class_name => 'UMT::UsageNote',  :conditions => { :owner_type => self.name }
  has_many :umt_change_notes, :foreign_key => 'owner_id', :class_name => 'UMT::ChangeNote', :conditions => { :owner_type => self.name }
  has_many :umt_export_notes, :foreign_key => 'owner_id', :class_name => 'UMT::ExportNote', :conditions => { :owner_type => self.name }
  @nested_relations += [:umt_source_notes, :umt_change_notes, :umt_usage_notes]

  Iqvoc::Concept.note_class_names.each do |class_name|
    relation_name = class_name.to_relation_name
    has_many relation_name, :class_name => class_name, :as => :owner
    @nested_relations << relation_name
  end

  # *** Matches (pointing to an other thesaurus)
  # FIXME: Must be configureable
  has_many :close_matches,    :class_name => Match::SKOS::Close.name
  has_many :broader_matches,  :class_name => Match::SKOS::Broader.name
  has_many :narrower_matches, :class_name => Match::SKOS::Narrower.name
  has_many :related_matches,  :class_name => Match::SKOS::Related.name
  has_many :exact_matches,    :class_name => Match::SKOS::Exact.name
  @nested_relations += [:close_matches]

  has_many :matches
  has_many :referenced_matches, :class_name => 'Match', :foreign_key => 'value'
  has_many :referenced_semantic_relations, :class_name => 'SemanticRelation', :foreign_key => 'target_id'

  # FIXME
  @nested_relations.each do |relation|
    accepts_nested_attributes_for relation, :allow_destroy => true, :reject_if => Proc.new {|attrs| attrs[:value].blank? }
  end

  scope :alphabetical, lambda {|letter| {
      :conditions => ["labelings.type = :type AND LOWER(SUBSTR(labels.value, 1, 1)) = :letter",
        {:type => 'PrefLabeling', :letter => letter.to_s}],
      :include => :pref_labels,
      :order => 'LOWER(labels.value)',
      :group => 'concepts.id' }
  }

  scope :by_language, lambda { |lang_code| {
      :conditions => { :language => lang_code.to_s } }
  }

  scope :tops,
    :conditions => "NOT EXISTS (SELECT DISTINCT sr.owner_id FROM  concept_relations sr WHERE sr.type = 'Broader' AND sr.owner_id = concepts.id) AND labelings.type = 'PrefLabeling'",
    :include => :pref_labels,
    :order => 'LOWER(labels.value)',
    :group => 'concepts.id, concepts.type, concepts.created_at, concepts.updated_at, concepts.origin, concepts.status, concepts.classified, concepts.country_code, concepts.rev, concepts.published_at, concepts.locked_by, concepts.expired_at, concepts.follow_up, labels.id, labels.created_at, labels.updated_at, labels.language, labels.value, labels.base_form, labels.inflectional_code, labels.part_of_speech, labels.status, labels.origin, labels.rev, labels.published_at, labels.locked_by, labels.expired_at, labels.follow_up, labels.endings'


  scope :broader_tops,
    :conditions => "NOT EXISTS (SELECT DISTINCT sr.target_id FROM concept_relations sr WHERE sr.type = 'Narrower' AND sr.owner_id = concepts.id GROUP BY sr.target_id) AND labelings.type = 'PrefLabeling'",
    :include => :pref_labels,
    :order => 'LOWER(labels.value)',
    :group => 'concepts.id'

  scope :with_associations, :include => [
    :pref_labels, :alt_labels, :hidden_labels,
    {:broader => :pref_labels}, {:narrower => :pref_labels}, {:related => :pref_labels},
    :classifiers,
    :close_matches, :broader_matches, :narrower_matches, :related_matches, :exact_matches,
    :notes, :history_notes, :scope_notes, :editorial_notes, :examples, :definitions,
    {:umt_source_notes => :note_annotations},
    {:umt_usage_notes => :note_annotations},
    {:umt_change_notes => :note_annotations},
    {:umt_export_notes => :note_annotations}
  ]

  scope :with_pref_labels,
    :include => :pref_labels,
    :conditions => {:labelings => {:type => 'PrefLabeling'}},
    :order => 'LOWER(labels.value)'

  scope :in_edit_mode,
    where(arel_table[:locked_by].eq(nil).complement)

  after_initialize :init_label_caches

  def self.associations_for_versioning
    [ 
      :labelings, 
      :semantic_relations, 
      :referenced_semantic_relations, 
      :matches, 
      :referenced_matches, 
      :classifications, 
      {:notes => :note_annotations}
    ]
  end

  def self.first_level_associations
    [
      :labelings, 
      :semantic_relations, 
      :referenced_semantic_relations, 
      :referenced_matches, 
      :matches, 
      :classifications, 
      :notes
    ]
  end

  def self.get_new_or_initial_version(origin)
    Concept.new_version(origin).first.blank? ? Concept.initial_version(origin).first : Concept.new_version(origin).first
  end

  def initialize(params = {})
    super(params)
    @full_validation = false
  end

  def pref_label
    pref_labels.first || nil # I18n.t("txt.models.concept.no_pref_label")
  end

  def init_label_caches
    @pl4l = {} # pref label caching hash to speed things up
    @al4l = {}
  end

  # returns the (one!) preferred label of a concept for the requested language.
  # lang can either be a (lowercase) string or symbol with the (ISO ....) two letter
  # code of the language (e.g. :en for English, :fr for French, :de for German).
  # if lang is NIL, :en will be used. If no prefLabel for the requested language exists,
  # a new label will be returned (if you modify it, don't forget to save it afterwards!)
  def pref_label_for_language(lang = :en)
    return @pl4l[lang] unless @pl4l[lang].nil?
    @pl4l[lang] = pref_labels.for_language(lang.to_s).first || pref_labels.new(:language => lang.to_s)
  end

  def alt_labels_for_language(lang = :en)
    return @al4l[lang] unless @al4l[lang].nil?
    @al4l[lang] = alt_labels.select {|al| al.language == lang.to_s}
    # @al4l[lang] = alt_labels.for_language(lang.to_s) || alt_labels.new(:language => lang.to_s)
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
      :semantic_relations => Concept::Relation::Base.target_in_edit_mode(id), 
      :labelings => Labeling::SKOSXL::Base.target_in_edit_mode(id)
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
      associations_for_validation = [
        :pref_labels, :alt_labels, :hidden_labels,
        :broader, :narrower, :related
      ]
      associations_for_validation.each do |method|
        if self.send(method).unpublished.any?
          errors.add(:base, I18n.t("txt.models.concept.association_#{method}_unpublished"))
        end
      end
    end
  end
end
