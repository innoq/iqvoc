class RemoveCollectionMembers < ActiveRecord::Migration
  def self.up
    drop_table :collection_members
  end

  def self.down
  end
end
