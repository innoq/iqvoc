class AddIndexesToCollections < ActiveRecord::Migration
  def self.up
    add_index :collections, [:origin, :type]
    add_index :collection_members, [:collection_id, :target_id, :type]
  end

  def self.down
  end
end
