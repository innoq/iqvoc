class Collection::Member::Collection < Collection::Member::Base
  
  belongs_to :subcollection, :class_name => 'Collection::Base', :foreign_key => 'target_id'
  
  def self.view_section(obj)
    "main"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/collection/member"
  end
  
end
