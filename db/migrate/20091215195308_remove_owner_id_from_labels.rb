class RemoveOwnerIdFromLabels < ActiveRecord::Migration
  def self.up
    remove_column :labels, :owner_id
  end

  def self.down
    add_column :labels, :owner_id, :integer
  end
end
