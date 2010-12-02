class RenameCollectionContentsToCollectionMembers < ActiveRecord::Migration
  def self.up
    rename_table(:collection_contents, :collection_members)
  end

  def self.down
    rename_table(:collection_members, :collection_contents)
  end
end
