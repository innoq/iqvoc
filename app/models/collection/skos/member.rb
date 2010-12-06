class Collection::SKOS::Member < ActiveRecord::Base

  set_table_name 'collection_members'
  
  belongs_to :concept, :class_name => Iqvoc::Concept.base_class_name
  belongs_to :collection, :class_name => "Collection::SKOS::Base"


  def self.view_section(obj)
    "main"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/collection/skos/member"
  end
  
end
