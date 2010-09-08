class Concept::SKOS::Base < ActiveRecord::Base

  include IqvocGlobal::CommonScopes
  include IqvocGlobal::CommonMethods
  include IqvocGlobal::CommonAssociations
  include IqvocGlobal::ConceptAssociationExtensions

  validate :origin, :presence => true
  validate :two_versions_exist,  :on => :create
  validate :pref_label_existence, :associations_must_be_published, :on => :update

  before_destroy :has_references?

  has_many :semantic_relations, :foreign_key => 'owner_id'

  [:narrower, :broader, :related].each do |name|
    has_many :"#{name}_relations",
      :foreign_key => :owner_id,
      :class_name => "#{name}".classify, :extend => [PushWithReflectionExtension, DestroyReflectionExtension]
    has_many name,
      :class_name => 'Concept',
      :source => :target,
      :through => "#{name}_relations".to_sym do
      define_method :'<<' do |target|
        klass = Kernel.const_get(name.to_s.classify)
        klass.find_or_create_by_target_id_and_owner_id target.read_attribute(:id), proxy_owner.id
        proxy_owner.send(name).reload
      end
    end
  end

  has_many :labelings, :foreign_key => 'owner_id'

  [:pref_labels, :alt_labels, :hidden_labels].each do |name|
    klass = "#{name.to_s.singularize}ing" # => pref_labeling
    has_many :"#{klass.pluralize}", :foreign_key => :owner_id
    has_many name, :source => :target, :through => :"#{klass.pluralize}" do

      define_method :'<<' do |target|
        klass = Kernel.const_get("#{name.to_s.singularize.classify}ing")
        klass.find_or_create_by_owner_id_and_target_id(proxy_owner.id, target.read_attribute(:id))
        proxy_owner.send(name).reload
      end

    end
  end

  has_many :classifications, :foreign_key => 'owner_id'
  has_many :classifiers, :through => :classifications, :source => :target

  has_many :umt_source_notes, :foreign_key => 'owner_id', :class_name => 'UMT::SourceNote', :conditions => { :owner_type => self.name }
  has_many :umt_usage_notes, :foreign_key => 'owner_id', :class_name => 'UMT::UsageNote', :conditions => { :owner_type => self.name }
  has_many :umt_change_notes, :foreign_key => 'owner_id', :class_name => 'UMT::ChangeNote', :conditions => { :owner_type => self.name }
  has_many :umt_export_notes, :foreign_key => 'owner_id', :class_name => 'UMT::ExportNote', :conditions => { :owner_type => self.name }

  [:notes, :history_notes, :scope_notes, :editorial_notes, :examples, :definitions].each do |name|
    has_many name, :as => :owner
  end

  has_many :close_matches
  has_many :broader_matches
  has_many :narrower_matches
  has_many :related_matches
  has_many :exact_matches

  #Versioning relations
  has_many :matches
  has_many :referenced_matches, :class_name => 'Match', :foreign_key => 'value'
  has_many :referenced_semantic_relations, :class_name => 'SemanticRelation', :foreign_key => 'target_id'

  #Nested Attributes stuff
  [:definitions, :editorial_notes, :umt_source_notes, :umt_change_notes, :umt_usage_notes, :close_matches].each do |relation|
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
    :conditions => "NOT EXISTS (SELECT DISTINCT sr.owner_id FROM semantic_relations sr WHERE sr.type = 'Broader' AND sr.owner_id = concepts.id) AND labelings.type = 'PrefLabeling'",
    :include => :pref_labels,
    :order => 'LOWER(labels.value)',
    :group => 'concepts.id, concepts.type, concepts.created_at, concepts.updated_at, concepts.origin, concepts.status, concepts.classified, concepts.country_code, concepts.rev, concepts.published_at, concepts.locked_by, concepts.expired_at, concepts.follow_up, labels.id, labels.created_at, labels.updated_at, labels.language, labels.value, labels.base_form, labels.inflectional_code, labels.part_of_speech, labels.status, labels.origin, labels.rev, labels.published_at, labels.locked_by, labels.expired_at, labels.follow_up, labels.endings'


  scope :broader_tops,
    :conditions => "NOT EXISTS (SELECT DISTINCT sr.target_id FROM semantic_relations sr WHERE sr.type = 'Narrower' AND sr.owner_id = concepts.id GROUP BY sr.target_id) AND labelings.type = 'PrefLabeling'",
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
    
  after_initialize :init_label_caches

  def self.associations_for_versioning
    [:labelings, :semantic_relations, :referenced_semantic_relations, :matches, :referenced_matches, :classifications, {:notes => :note_annotations}]
  end

  def self.first_level_associations
    [:labelings, :semantic_relations, :referenced_semantic_relations, :referenced_matches, :matches, :classifications, :notes]
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
    {:semantic_relations => SemanticRelation.target_in_edit_mode(id), :labelings => Labeling.target_in_edit_mode(id)}
  end
    
  def rdf_uri(opts = {})
    "#{Rails.application.config.rdf_data_uri_prefix}#{origin}#{(opts[:format] ? "?format=#{CGI.escape(opts[:format].to_s)}" : "")}"
  end

  protected

  def two_versions_exist
    errors.add(:base, I18n.t("txt.models.concept.version_error")) if Concept.by_origin(self.origin).size >= 2
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
      errors.add(:base, I18n.t("txt.models.concept.pref_label_error")) if pref_labels.size == 0
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
