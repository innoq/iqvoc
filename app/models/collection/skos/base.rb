class Collection::SKOS::Base < ActiveRecord::Base
  
  set_table_name 'collections'
  
  has_many :language_notes, :class_name => 'Note::Iqvoc::LanguageNote'
  has_many :definitions, :class_name => 'Note::SKOS::Definition'
  has_many :contents, :class_name => 'Collection::SKOS::Content', :foreign_key => 'collection_id'
  
end
