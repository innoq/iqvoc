class FixCollectionMemberTypes < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE collection_members SET type ='Collection::Member::SKOS::Base' WHERE type = 'Collection::Member::Collection'"
  end

  def down
  end
end
