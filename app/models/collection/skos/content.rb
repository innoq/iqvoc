class Collection::SKOS::Content < ActiveRecord::Base

  set_table_name 'collection_contents'
  
  belongs_to :concept, :class_name => Iqvoc::Concept.base_class_name
  
end
