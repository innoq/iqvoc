class AddIndexesToCollections < ActiveRecord::Migration
  def self.up
    add_index :collections, [:origin, :type], :name => "ix_collections_origin_type"
    add_index :collection_members, [:collection_id, :target_id, :type], :name => "ix_collections_fk_type"
  end

  def self.down
  end
end
