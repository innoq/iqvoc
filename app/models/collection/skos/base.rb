class Collection::SKOS::Base < ActiveRecord::Base
  
  set_table_name 'collections'

  has_many Note::Iqvoc::LanguageNote.name.to_relation_name, 
    :class_name => 'Note::Iqvoc::LanguageNote', 
    :as => :owner,
    :dependent => :destroy
    
  has_many Note::SKOS::Definition.name.to_relation_name, 
    :class_name => 'Note::SKOS::Definition', 
    :as => :owner,
    :dependent => :destroy
    
  has_many :members,
    :class_name => 'Collection::SKOS::Member',
    :foreign_key => 'collection_id',
    :dependent => :destroy

  has_many :concepts,
    :through => :members

  accepts_nested_attributes_for :note_iqvoc_language_notes, :note_skos_definitions, 
    :allow_destroy => true, 
    :reject_if => Proc.new { |attrs| attrs[:value].blank? }
    
  after_save :regenerate_members

  before_validation(:on => :create) do
    self.origin ||= "_#{(self.class.maximum(:id) || 0) + 1}"
  end

  scope :by_origin, lambda { |origin|
    where(:origin => origin)
  }

  validates_uniqueness_of :origin
  validates :origin, :presence => true, :length => { :minimum => 2 }

  def self.note_class_names
    ['Note::Iqvoc::LanguageNote', 'Note::SKOS::Definition']
  end
  
  def self.note_classes
    note_class_names.map(&:constantize)
  end

  def to_param
    self.origin
  end

  def build_rdf_subject(document, controller, &block)
    IqRdf.build_uri(self.origin, IqRdf::Skos::build_uri("Collection"), &block)
  end

  def member_ids=(ids)
    @member_ids = ids.to_s.split(',').map(&:strip)
  end
  
  def regenerate_members
    return if members.empty? && @member_ids.blank?
    members.destroy_all
    @member_ids.each do |member_id|
      members.create!(:concept_id => member_id)
    end
  end
  
  def localized_note
    if val = note_iqvoc_language_notes.by_language(I18n.locale).first || note_iqvoc_language_notes.first
      val
    else
      origin
    end
  end
  
  def notes_for_class(note_class)
    note_class = note_class.name if note_class < ActiveRecord::Base # Use the class name string
    notes.select{ |note| note.class.name == note_class }
  end
  
end
