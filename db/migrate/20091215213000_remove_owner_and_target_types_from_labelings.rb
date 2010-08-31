class RemoveOwnerAndTargetTypesFromLabelings < ActiveRecord::Migration
  def self.up
    remove_column :labelings, :owner_type
    remove_column :labelings, :target_type
  end

  def self.down
    add_column :labelings, :owner_type, :string
    add_column :labelings, :target_type, :string
  end
end
