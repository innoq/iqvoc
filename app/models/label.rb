class Label < ActiveRecord::Base

  include IqvocGlobal::CommonScopes
  include IqvocGlobal::CommonMethods
  include IqvocGlobal::CommonAssociations
  
  attr_reader :inflectionals_attributes

  validate :two_versions_exist, :on => :create
  validate :value, :presence => true, :message => I18n.t("txt.models.label.value_error")
  
  # Run these validations if @full_validation is true
  validate :homograph_and_qualifier_existence, 
           :compound_form_contents_size,
           :pref_label_language,
           :translations_must_be_in_foreign_language

  before_destroy :has_references?
  after_save :overwrite_inflectionals!
  after_create :after_branch

  [:notes, :history_notes, :scope_notes, :editorial_notes, :examples, :definitions].each do |name|
    has_many name, :as => :owner, :dependent => :destroy
  end
  
  has_many :inflectionals, :dependent => :destroy

  has_many :labelings, :foreign_key => 'target_id'
  has_many :pref_labelings, :foreign_key => 'target_id'
  has_many :alt_labelings, :foreign_key => 'target_id'
  has_many :hidden_labelings, :foreign_key => 'target_id'
  
  has_many :concepts, :source => :owner, :through => :labelings
  has_many :concepts_as_pref_label, :source => :owner, :through => :pref_labelings, :conditions => "concepts.published_at IS NOT NULL"
  has_many :concepts_as_alt_label, :source => :owner, :through => :alt_labelings, :conditions => "concepts.published_at IS NOT NULL"
  has_many :concepts_as_hidden_label, :source => :owner, :through => :hidden_labelings, :conditions => "concepts.published_at IS NOT NULL"
  
  has_many :umt_source_notes, :foreign_key => 'owner_id', :class_name => 'UMT::SourceNote', :conditions => { :owner_type => self.name }, :dependent => :destroy
  has_many :umt_usage_notes, :foreign_key => 'owner_id', :class_name => 'UMT::UsageNote', :conditions => { :owner_type => self.name }, :dependent => :destroy
  has_many :umt_change_notes, :foreign_key => 'owner_id', :class_name => 'UMT::ChangeNote', :conditions => { :owner_type => self.name }, :dependent => :destroy
  has_many :umt_export_notes, :foreign_key => 'owner_id', :class_name => 'UMT::ExportNote', :conditions => { :owner_type => self.name }, :dependent => :destroy

  has_many :note_annotations, :through => :notes

  has_many :compound_forms, :foreign_key => 'domain_id', :class_name => 'UMT::CompoundForm', :dependent => :destroy
  has_many :compound_form_contents, :through => :compound_forms, :class_name => 'UMT::CompoundFormContent' 

  has_many :reverse_compound_form_contents, :foreign_key => 'label_id', :class_name => 'UMT::CompoundFormContent' 
  
  has_many :homographs, :foreign_key => 'domain_id', :class_name => 'UMT::Homograph', :dependent => :destroy
  has_many :qualifiers, :foreign_key => 'domain_id', :class_name => 'UMT::Qualifier', :dependent => :destroy
  has_many :translations, :foreign_key => 'domain_id', :class_name => 'UMT::Translation', :dependent => :destroy
  has_many :lexical_extensions, :foreign_key => 'domain_id', :class_name => 'UMT::LexicalExtension', :dependent => :destroy

  #Helper methods for the versioning
  has_many :label_relations, :foreign_key => 'domain_id'
  has_many :referenced_label_relations, :class_name => 'LabelRelation', :foreign_key => 'range_id'
  
  [:definitions, :editorial_notes, :umt_source_notes, :umt_change_notes, :umt_usage_notes].each do |relation|
    accepts_nested_attributes_for relation, :allow_destroy => true, :reject_if => Proc.new {|attrs| attrs[:value].blank? }
  end
  
  scope :by_origin_or_id, lambda { |arg|
    { :conditions => ['origin = :arg OR id = :arg', {:arg => arg}] }
  }

  scope :for_language, lambda {|lang_code|
    { :conditions => { :language => lang_code } }
  }
  
  scope :compound_in, lambda {|label|
    { :conditions => {:compound_form_contents => {:label_id => label.id}}, :joins => :compound_form_contents }
  }

  scope :with_associations, :include => [
    :inflectionals,
    :notes, :history_notes, :scope_notes, :editorial_notes, :examples, :definitions,
    {:umt_source_notes => :note_annotations},
    {:umt_usage_notes => :note_annotations},
    {:umt_change_notes => :note_annotations},
    {:umt_export_notes => :note_annotations},
    {:homographs => :range}, {:qualifiers => :range}, {:translations => :range},
    {:compound_form_contents => :label}
  ]

  #Class-Methods
  def self.associations_for_versioning
    [:labelings, :inflectionals, :label_relations, :referenced_label_relations, :reverse_compound_form_contents, {:notes => :note_annotations}, {:compound_forms => :compound_form_contents}]
  end

  def self.first_level_associations
    [:labelings, :inflectionals, :label_relations, :referenced_label_relations, :reverse_compound_form_contents, :notes, :compound_forms]
  end

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

  def self.get_new_or_initial_version(origin)
    Label.new_version(origin).first.blank? ? Label.initial_version(origin).first : Label.new_version(origin).first
  end

  #Instance-Methods
  def initialize(params = {})
   super(params)
   @full_validation = false
  end

  def <=>(other)
    value.to_s.downcase <=> other.to_s.downcase
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
  
  def literal_form
    "\"#{value}\"@#{language}"
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
  
  def to_s
    "#{value}"
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

  def homograph_and_qualifier_existence
    if @full_validation == true
      if homographs.size >= 1
       errors.add(:base, I18n.t("txt.models.label.qualifier_error")) unless qualifiers.size >= 1
      end
      if qualifiers.length >= 1
       errors.add(:base, I18n.t("txt.models.label.homograph_error")) unless homographs.size >= 1
      end
    end
  end

  def compound_form_contents_size
    if @full_validation == true
    unless compound_forms.blank?
      compound_forms.each do |cf|
        errors.add(:base, I18n.t("txt.models.label.compound_form_contents_error")) if cf.compound_form_contents.size < 2 
      end
    end
   end
  end
  
  def pref_label_language
    if @full_validation == true
      if language != "de" && pref_labelings.any?
        errors.add(:base, I18n.t("txt.models.label.pref_label_language"))
      end
    end
  end
  
  def translations_must_be_in_foreign_language
    if @full_validation == true
      if translations.count(:joins => :range, :conditions => {:labels => {:language => language}}) > 0
        errors.add(:base, I18n.t("txt.models.label.translations_must_be_in_foreign_language"))
      end
    end
  end

  #Callbacks
  def has_references?
    if (self.referenced_label_relations.size != 0) || (self.pref_labelings.size != 0)
      false
    else
      true
    end
  end
end
