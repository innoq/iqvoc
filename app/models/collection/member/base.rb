class Collection::Member::Base < ActiveRecord::Base

  set_table_name 'collection_members'
  
  belongs_to :collection, :class_name => 'Collection::Base'
  
end
