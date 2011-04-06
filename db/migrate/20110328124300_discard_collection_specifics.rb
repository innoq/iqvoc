class DiscardCollectionSpecifics < ActiveRecord::Migration
  def self.up
    drop_table :collections
    drop_table :collection_labels
  end

  def self.down
    # irreversible
  end
end
