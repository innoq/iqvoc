class FixCollectionMemberTypes < ActiveRecord::Migration
  def up
    execute "UPDATE collection_members SET type ='Collection::Member::SKOS::Base' WHERE type = 'Collection::Member::Collection'"
  end

  def down
  end
end
