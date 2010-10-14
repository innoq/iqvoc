# FIXME: Not much flexiblity refactorings done yet
class Label::SKOSXL::Base < Label::Base

  include IqvocGlobal::Versioning
  
  # ********** Validations

  validate :two_versions_exist, :on => :create

  # ********** Hooks

  before_destroy :has_references?

  # ********** "Static"/unconfigureable relations

  @nested_relations = [] # Will be marked as nested attributes later

  has_many :labelings, :class_name => 'Labeling::Base', :foreign_key => 'target_id', :dependent => :destroy
  has_many :concepts, :through => :labelings, :source => :owner
  include_to_deep_cloning(:labelings)

  has_many :relations, :foreign_key => 'domain_id', :class_name => 'Label::Relation::Base', :dependent => :destroy
  # Which references are pointing to this label?
  has_many :referenced_by_relations, :foreign_key => 'range_id', :class_name => 'Label::Relation::Base', :dependent => :destroy
  include_to_deep_cloning(:relations, :referenced_by_relations)

  has_many :notes, :as => :owner, :class_name => 'Note::Base', :dependent => :destroy
  has_many :annotations, :through => :notes, :source => :annotations
  include_to_deep_cloning(:notes => :annotations)

  # The following would be nice but isn't working :-)
  #has_many :reverse_compound_form_labels, :class_name => 'Label::Base', :through => :reverse_compound_forms, :source => :domain
  
  # ************** "Dynamic"/configureable relations

  Iqvoc::XLLabel.note_class_names.each do |note_class_name|
    has_many note_class_name.to_relation_name, :as => :owner, :class_name => note_class_name, :dependent => :destroy
    @nested_relations << note_class_name.to_relation_name
  end
  
  Iqvoc::XLLabel.relation_class_names.each do |relation_class_name|
    has_many relation_class_name.to_relation_name,
      :foreign_key => 'domain_id',
      :class_name  => relation_class_name,
      :dependent   => :destroy
  end

  if Iqvoc::XLLabel.compound_form_class_name
    has_many Iqvoc::XLLabel.compound_form_class_name.to_relation_name,
      :foreign_key => 'domain_id',
      :class_name  => Iqvoc::XLLabel.compound_form_class_name
    has_many Iqvoc::XLLabel.compound_form_content_class_name.to_relation_name,
      :class_name  => Iqvoc::XLLabel.compound_form_content_class_name,
      :through     => Iqvoc::XLLabel.compound_form_class_name.to_relation_name
  end

  Iqvoc::XLLabel.additional_association_classes.each do |association_class, foreign_key|
    has_many association_class.name.to_relation_name, :class_name => association_class.name, :foreign_key => foreign_key, :dependent => :destroy
    include_to_deep_cloning(association_class.deep_cloning_relations)
    association_class.referenced_by(self)
  end

  # ********** Relation Stuff
  
  @nested_relations.each do |relation|
    accepts_nested_attributes_for relation, :allow_destroy => true, :reject_if => Proc.new {|attrs| attrs[:value].blank? }
  end

  # ********** Scopes

  scope :by_origin, lambda { |origin|
    where(:origin => origin)
  }

  # FIXME This should be working again
  scope :with_associations, lambda { includes(:labelings => :owner) }
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

  def self.from_rdf(str)
    h = IqvocGlobal::RdfHelper.split_literal(str)
    self.new(:value => h[:value], :language => h[:language])
  end
  
  def self.from_rdf!(str)
    self.from_rdf(str).save!
  end

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
  
  def to_param
    origin
  end
  
  def customized_to_json(options = {})
    {
      'id'   => self.id,
      'name' => self.origin     
    }
  end

  def has_concept_or_label_relations?
    if labelings.count > 0 || label_relations.count > 0 || compound_forms.count > 0
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
    {
      :label_relations => Label::Relation::Base.by_domain(id).range_in_edit_mode,
# FIXME      :compound_from_contents => UMT::CompoundFormContent.target_in_edit_mode(id)
    }
  end
  
  def rdf_uri(opts = {})
    "#{Rails.application.config.rdf_data_uri_prefix}#{origin}#{(opts[:format] ? "?format=#{CGI.escape(opts[:format].to_s)}" : "")}"
  end
  
  protected

  def two_versions_exist
    errors.add(:base, I18n.t("txt.models.label.version_error")) if Label::SKOSXL::Base.by_origin(origin).count >= 2
  end

  def has_references?
    if (self.referenced_label_relations.count != 0) || (self.pref_labelings.count != 0)
      false
    else
      true
    end
  end
end
