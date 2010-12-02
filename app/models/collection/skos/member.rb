class Collection::SKOS::Member < ActiveRecord::Base

  set_table_name 'collection_members'
  
  belongs_to :concept, :class_name => Iqvoc::Concept.base_class_name
  belongs_to :collection, :class_name => "Collection::SKOS::Base"
  
end
