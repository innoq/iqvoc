class FixCollectionType < ActiveRecord::Migration
  def up
    execute "UPDATE concepts SET type='Collection::SKOS::Unordered' WHERE type='Collection::Unordered'"    
    execute "UPDATE collection_members SET type='Collection::Member::SKOS::Base' WHERE type='Collection::Member::Concept'"    
  end

  def down
    execute "UPDATE concepts SET type='Collection::Unordered' WHERE type='Collection::SKOS::Unordered'"
  end
end
