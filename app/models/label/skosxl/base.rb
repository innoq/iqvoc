# FIXME: Not much flexiblity refactorings done yet
class Label::SKOSXL::Base < Label::Base

  include IqvocGlobal::CommonScopes
  include IqvocGlobal::CommonMethods
  include IqvocGlobal::CommonAssociations
  
  attr_reader :inflectionals_attributes

  # ********** Validations

  validate :two_versions_exist, :on => :create
  
  # Run these validations if @full_validation is true
  validate :compound_form_contents_size
  #, :homograph_and_qualifier_existence,
  # :translations_must_be_in_foreign_language
  # :pref_label_language

  # ********** Hooks

  before_destroy :has_references?
  after_save :overwrite_inflectionals!
  after_create :after_branch

  # ********** "Static"/unconfigureable relations

  @nested_relations = [] # Will be marked as nested attributes later

  has_many :labelings, :class_name => 'Labeling::Base', :foreign_key => 'target_id'
  has_many :concepts, :through => :labelings, :source => :owner

  has_many :relations, :foreign_key => 'domain_id', :class_name => 'Label::Relation::Base'
  # Which references are pointing to this label?
  has_many :referenced_by_relations, :foreign_key => 'range_id', :class_name => 'Label::Relation::Base'

  has_many :notes, :as => :owner, :class_name => 'Note::Base', :dependent => :destroy
  has_many :annotations, :through => :notes, :source => :annotations

  has_many :inflectionals, :class_name => 'Inflectional::Base', :foreign_key => 'label_id', :dependent => :destroy

  has_many :compound_forms, :class_name => 'CompoundForm::Base', :foreign_key => 'domain_id'
  has_many :compound_form_contents, :class_name => "CompoundForm::Content::Base", :through => :compound_forms, :source => :compound_form_contents, :dependent => :destroy
  # Where is this label references as CompoundFormContent?
  has_many :reverse_compound_form_contents, :class_name => 'CompoundForm::Content::Base', :foreign_key => 'label_id'
  has_many :reverse_compound_forms, :class_name => 'CompoundForm::Base', :through => :reverse_compound_form_contents, :source => :compound_form
  # The following would be nice but isn't working :-)
  #has_many :reverse_compound_form_labels, :class_name => 'Label::Base', :through => :reverse_compound_forms, :source => :domain
  
  # ************** "Dynamic"/configureable relations

  Iqvoc::Label.note_class_names.each do |note_class_name|
    has_many note_class_name.to_relation_name, :as => :owner, :class_name => note_class_name, :dependent => :destroy
    @nested_relations << note_class_name.to_relation_name
  end
  
  Iqvoc::Label.relation_class_names.each do |relation_class_name|
    has_many relation_class_name.to_relation_name,
      :foreign_key => 'domain_id',
      :class_name  => relation_class_name,
      :dependent   => :destroy
  end

  if Iqvoc::Label.compound_form_class_name
    has_many Iqvoc::Label.compound_form_class_name.to_relation_name,
      :foreign_key => 'domain_id',
      :class_name  => Iqvoc::Label.compound_form_class_name
    has_many Iqvoc::Label.compound_form_content_class_name.to_relation_name,
      :class_name  => Iqvoc::Label.compound_form_content_class_name,
      :through     => Iqvoc::Label.compound_form_class_name.to_relation_name
  end

  # ********** Relation Stuff
  
  @nested_relations.each do |relation|
    accepts_nested_attributes_for relation, :allow_destroy => true, :reject_if => Proc.new {|attrs| attrs[:value].blank? }
  end

  # ********** Scopes
  
  scope :by_origin_or_id, lambda { |arg|
    { :conditions => ['origin = :arg OR id = :arg', {:arg => arg}] }
  }

  # FIXME This should be working again
  scope :with_associations, includes(:labelings => :owner)
  #, :include => [
  # :inflectionals,
  # :notes, :history_notes, :scope_notes, :editorial_notes, :examples, :definitions,
  # {:umt_source_notes => :annotations},
  # {:umt_usage_notes => :annotations},
  # {:umt_change_notes => :annotations},
  # {:umt_export_notes => :annotations},
  # {:homographs => :range}, {:qualifiers => :range}, {:translations => :range},
  # {:compound_form_contents => :label}
  # ]
  
  # ********** Methods

  #Class-Methods
  def self.associations_for_versioning
    [:labelings, :inflectionals, :label_relations, :referenced_label_relations, :reverse_compound_form_contents, {:notes => :annotations}, {:compound_forms => :compound_form_contents}]
  end

  def self.first_level_associations
    [:labelings, :inflectionals, :label_relations, :referenced_label_relations, :reverse_compound_form_contents, :notes, :compound_forms]
  end

  # FIXME: Seems not to bee used => KILL IT! :-)
  def self.pref_label_alphas
    Label.all(
      :select => "SUBSTR(LOWER(labels.value), 1, 1) AS alpha", 
      :joins  => :pref_labelings,
      :group  => :alpha).map {|label| label.alpha}
  end
  
  def self.from_rdf(str)
    h = IqvocGlobal::RdfHelper.split_literal(str)
    self.new(:value => h[:value], :language => h[:language])
  end
  
  def self.from_rdf!(str)
    self.from_rdf(str).save!
  end

  #Instance-Methods
  def initialize(params = {})
    super(params)
    @full_validation = false
  end

  def concepts_for_labeling_class(labeling_class)
    labeling_class = labeling_class.name if labeling_class < ActiveRecord::Base # Use the class name string
    labelings.select{ |l| l.class.name == labeling_class.to_s }.map(&:owner)
  end

  def related_labels_for_relation_class(relation_class)
    relation_class = relation_class.name if relation_class < ActiveRecord::Base # Use the class name string
    relations.select{ |rel| rel.class.name == relation_class }.map(&:range)
  end

  def notes_for_class(note_class)
    note_class = note_class.name if note_class < ActiveRecord::Base # Use the class name string
    notes.select{ |note| note.class.name == note_class }
  end

  def endings
    Inflectional.for_language_and_code(language, inflectional_code)
  end
  
  def from_rdf(str)
    h = IqvocGlobal::RdfHelper.split_literal(str)
    self.value    = h[:value]
    self.language = h[:language]
    self
  end
  
  def from_rdf!(str)
    from_rdf(str)
    save(:validate => false)
  end
  
  def generate_inflectionals!
    return inflectionals if base_form.blank?
    
    helper = OriginMapping.new
    
    converted_literal_form = helper.replace_umlauts(value)
    
    diff = helper.sanitize_for_base_form(converted_literal_form).size - base_form.size
    
    unless base_form.blank?
      new_base_form = converted_literal_form[0..(base_form.length-1)]
    end
    
    Rails.logger.debug "converted_literal_form => #{converted_literal_form} (#{converted_literal_form.size}) |
          base_form => #{base_form} (#{base_form.size}) |
          new_base_form => #{new_base_form} | 
          value => #{value} (#{value.size}) |
          diff => #{diff}"
    
    endings.each do |ending|
      value = ending == "." ? new_base_form : (new_base_form + ending.downcase)
      inflectionals.create!(:value => value)
    end
    
    self.base_form = new_base_form
    save(:validate => false)
    
    inflectionals
  end
  
  def inflectionals_attributes=(str)
    @inflectionals_attributes = str.split("\r\n")
  end
  
  def overwrite_inflectionals!
    return unless inflectionals_attributes
    transaction do
      inflectionals.delete_all
      inflectionals_attributes.each do |value|
        inflectionals.create!(:value => value)
      end
    end
  end
  
  def to_param
    origin
  end
  
  def collect_first_level_associated_objects
    associated_objects = Array.new
    Label.first_level_associations.each do |association|
      associated_objects << self.send(association)
    end
    associated_objects.flatten
  end

  def customized_to_json(options = {})
    {
      'id' => self.id,
      'name' => self.origin     
    }
  end

  def has_concept_or_label_relations?
    if labelings.size > 0 || label_relations.size > 0 || compound_forms.size > 0
      true
    else
      false
    end
  end

  def save_with_full_validation!
    @full_validation = true
    save!
  end
  
  # FIXME: should not @full_validation be set back to the value it had before??? This method changes the state!
  def valid_with_full_validation?
    @full_validation = true
    valid?
  end

  def associated_objects_in_editing_mode
    {:label_relations => LabelRelation.range_in_edit_mode(id), :compound_from_contents => UMT::CompoundFormContent.target_in_edit_mode(id)}
  end
  
  def rdf_uri(opts = {})
    "#{Rails.application.config.rdf_data_uri_prefix}#{origin}#{(opts[:format] ? "?format=#{CGI.escape(opts[:format].to_s)}" : "")}"
  end
  
  protected

  #Validations
  def two_versions_exist
    errors.add(:base, I18n.t("txt.models.label.version_error")) if Label.by_origin(self.origin).size >= 2
  end

  # FIXME: Homographs etc are UMT models... The the validations can't stay here
  # def homograph_and_qualifier_existence
  #  if @full_validation == true
  #    if homographs.size >= 1
  #      errors.add(:base, I18n.t("txt.models.label.homograph_error")) unless qualifiers.size >= 1
  #    end
  #    if qualifiers.length >= 1
  #      errors.add(:base, I18n.t("txt.models.label.qualifier_error")) unless homographs.size >= 1
  #    end
  #  end
  #end

  def compound_form_contents_size
    if @full_validation == true
      unless compound_forms.blank?
        compound_forms.each do |cf|
          errors.add(:base, I18n.t("txt.models.label.compound_form_contents_error")) if cf.compound_form_contents.size < 2
        end
      end
    end
  end

  # FIXME: This is very UMT specific!
  # def pref_label_language
  #  if @full_validation == true
  #    if language != "de" && pref_labelings.any?
  #      errors.add(:base, I18n.t("txt.models.label.pref_label_language"))
  #    end
  #  end
  #end
  
  # FIXME: Translations are UMT models... The the validation can't stay here
  # def translations_must_be_in_foreign_language
  #  if @full_validation == true
  #    if translations.count(:joins => :range, :conditions => {:labels => {:language => language}}) > 0
  #      errors.add(:base, I18n.t("txt.models.label.translations_must_be_in_foreign_language"))
  #    end
  #  end
  #end

  #Callbacks
  def has_references?
    if (self.referenced_label_relations.size != 0) || (self.pref_labelings.size != 0)
      false
    else
      true
    end
  end
end
