class AddTypeToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :type, :string
  end

  def self.down
  end
end
