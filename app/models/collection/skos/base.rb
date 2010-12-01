class Collection::SKOS::Base < ActiveRecord::Base
  
  set_table_name 'collections'
  
  has_many Note::Iqvoc::LanguageNote.name.to_relation_name, 
    :class_name => 'Note::Iqvoc::LanguageNote', 
    :foreign_key => 'collection_id',
    :as => :owner,
    :dependent => :destroy
    
  has_many Note::SKOS::Definition.name.to_relation_name, 
    :class_name => 'Note::SKOS::Definition', 
    :foreign_key => 'collection_id',
    :as => :owner,
    :dependent => :destroy
    
  has_many Collection::SKOS::Content.name.to_relation_name, 
    :class_name => 'Collection::SKOS::Content', 
    :foreign_key => 'collection_id',
    :dependent => :destroy
  
  accepts_nested_attributes_for :note_iqvoc_language_notes, :note_skos_definitions, 
    :allow_destroy => true, 
    :reject_if => Proc.new { |attrs| attrs[:value].blank? }
    
  after_save :regenerate_contents
    
  def self.note_class_names
    ['Note::Iqvoc::LanguageNote', 'Note::SKOS::Definition']
  end
  
  def self.note_classes
    note_class_names.map(&:constantize)
  end

  def content_ids=(ids)
    @content_ids = ids.to_s.split(',').map(&:strip)
  end
  
  def regenerate_contents
    return if collection_skos_contents.empty? && @content_ids.blank?
    collection_skos_contents.destroy_all
    @content_ids.each do |content_id|
      collection_skos_contents.create!(:concept_id => content_id)
    end
  end
  
  def localized_note
    if val = note_iqvoc_language_notes.by_language(I18n.locale).first
      val
    else
      id
    end
  end
  
  def notes_for_class(note_class)
    note_class = note_class.name if note_class < ActiveRecord::Base # Use the class name string
    notes.select{ |note| note.class.name == note_class }
  end
  
end
