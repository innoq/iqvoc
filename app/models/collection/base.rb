class Collection::Base < Concept::Base

  has_many Note::SKOS::Definition.name.to_relation_name,
    :class_name => 'Note::SKOS::Definition',
    :as => :owner,
    :dependent => :destroy

  has_many :members,
    :class_name  => 'Collection::Member::Base',
    :foreign_key => 'collection_id',
    :dependent   => :destroy

  has_many :concept_members,
    :class_name  => 'Collection::Member::Concept',
    :foreign_key => 'collection_id',
    :dependent   => :destroy

  has_many :concepts,
    :through => :concept_members

  has_many :collection_members,
    :class_name  => 'Collection::Member::Collection',
    :foreign_key => 'collection_id',
    :dependent   => :destroy

  has_many :subcollections,
    :through => :collection_members

  # XXX: fails after removing collection_labels!?
  #accepts_nested_attributes_for :note_skos_definitions,
  #  :allow_destroy => true,
  #  :reject_if => Proc.new { |attrs| attrs[:value].blank? }

  after_save :regenerate_concept_members, :regenerate_collection_members

  before_validation(:on => :create) do
    self.origin ||= "_#{(self.class.maximum(:id) || 0) + 1}"
  end

  scope :by_origin, lambda { |origin|
    where(:origin => origin)
  }

  scope :by_label_value, lambda { |val|
    includes(:labels).merge(Label::Base.by_query_value(val))
  }

  validates_uniqueness_of :origin
  validates :origin, :presence => true, :length => { :minimum => 2 }
  validate :circular_subcollections

  def self.note_class_names
    ['Note::SKOS::Definition']
  end

  def self.note_classes
    note_class_names.map(&:constantize)
  end

  def to_param
    self.origin
  end

  def build_rdf_subject(document, controller, &block)
    IqRdf::Coll::build_uri(self.origin, IqRdf::Skos::build_uri("Collection"), &block)
  end

  def inline_member_concept_origins=(origins)
    @member_concept_origins = origins.to_s.split(',').map(&:strip)
  end

  def inline_member_concept_origins
    @member_concept_origins || concept_members.map{|m| m.concept.origin}.uniq
  end

  def inline_member_concepts
    Concept::Base.editor_selectable.where(:origin => inline_member_concept_origins)
  end

  def inline_member_collection_origins=(origins)
    @member_collection_origins = origins.to_s.split(',').map(&:strip)
  end

  def inline_member_collection_origins
    @member_collection_origins || collection_members.map{|m| m.subcollection.origin}.uniq
  end

  def inline_member_collections
    Collection::Base.where(:origin => inline_member_collection_origins)
  end

  def regenerate_concept_members
    return if @member_concept_origins.nil? # There is nothing to do
    existing_concept_origins = concept_members.map{|m| m.concept.origin}.uniq
    (@member_concept_origins - existing_concept_origins).each do |new_origin|
      Concept::Base.by_origin(new_origin).each do |c|
        concept_members.create!(:target_id => c.id)
      end
    end
    concept_members.includes(:concept).where("#{Concept::Base.table_name}.origin" => (existing_concept_origins - @member_concept_origins)).destroy_all()
  end

  def regenerate_collection_members
    return if @member_collection_origins.nil? # There is nothing to do
    existing_collection_origins = collection_members.map{ |m| m.collection.origin }.uniq
    (@member_collection_origins - existing_collection_origins).each do |new_origin|
      Iqvoc::Collection.base_class.where(:origin => new_origin).each do |c|
        collection_members.create!(:target_id => c.id)
      end
    end
    collection_members.
      includes(:collection).
      where("#{Collection::Base.table_name}.origin" => (existing_collection_origins - @member_collection_origins)).
      destroy_all()
  end

  def label
    pref_label(I18n.locale) || labels.first || origin
  end

  # def notes_for_class(note_class)
  #   note_class = note_class.name if note_class < ActiveRecord::Base # Use the class name string
  #   notes.select{ |note| note.class.name == note_class }
  # end

  def circular_subcollections
    Iqvoc::Collection.base_class.by_origin(@member_collection_origins).each do |subcollection|
      if subcollection.subcollections.all.include?(self)
        errors.add(:base,
            I18n.t("txt.controllers.collections.circular_error") % subcollection.label)
      end
    end
  end

end
