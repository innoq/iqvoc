class Label::SKOSXL::Base < Label::Base

  include IqvocGlobal::Versioning
  
  # ********** Validations

  validate :two_versions_exist, :on => :create

  # ********** Hooks

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

  scope :with_associations, lambda { includes(:labelings => :owner) }
  
  # ********** Methods
  
  def self.single_query(params = {})
    query_str = build_query_string(params)
    
    by_query_value(query_str).
    by_language(params[:languages].to_a).
    published.
    order("LOWER(#{Label::Base.arel_table[:value].to_sql})")
  end
  
  def self.search_result_partial_name
    'partials/label/search/result'
  end

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
    # Check if one of the additional association methods return elements
    Iqvoc::XLLabel.additional_association_classes.each do |association_class, foreign_key|
      return true if send(association_class.name.to_relation_name).count > 0
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

  # Responsible for displaying a warning message about
  # associated objects which are currently edited y another user.
  def associated_objects_in_editing_mode
    {
      :label_relations => Label::Relation::Base.by_domain(id).range_in_edit_mode
    }
  end
  
  def rdf_uri(opts = {})
    "#{Rails.application.config.rdf_data_uri_prefix}#{origin}#{(opts[:format] ? "?format=#{CGI.escape(opts[:format].to_s)}" : "")}"
  end
  
  protected

  def two_versions_exist
    errors.add(:base, I18n.t("txt.models.label.version_error")) if Label::SKOSXL::Base.by_origin(origin).count >= 2
  end

end
