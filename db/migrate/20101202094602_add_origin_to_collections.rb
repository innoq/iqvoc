class AddOriginToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :origin, :string
  end

  def self.down
    remove_column :collections, :origin
  end
end
