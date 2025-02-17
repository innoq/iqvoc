class FixCollectionType < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE concepts SET type='Collection::Skos::Unordered' WHERE type='Collection::Unordered'"
    execute "UPDATE collection_members SET type='Collection::Member::Skos::Base' WHERE type='Collection::Member::Concept'"
  end

  def down
    execute "UPDATE concepts SET type='Collection::Unordered' WHERE type='Collection::Skos::Unordered'"
  end
end
