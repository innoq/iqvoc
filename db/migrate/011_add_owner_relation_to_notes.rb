class AddOwnerRelationToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :owner_id, :integer
    add_column :notes, :owner_type, :string, :limit => 50, :default => 'Concept', :null => false
  end

  def self.down
    remove_column :notes, :owner_id
    remove_column :notes, :owner_type
  end
end
