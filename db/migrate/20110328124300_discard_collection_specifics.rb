class DiscardCollectionSpecifics < ActiveRecord::Migration
  def self.up
    drop_table :collections
    drop_table :collection_labels
  end

  def self.down
    create_table :collections
    create_table :collection_labels
  end
end
