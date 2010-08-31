class RemoveTypeFromLabels < ActiveRecord::Migration
  def self.up
    remove_column :labels, :type
  end

  def self.down
    add_column :labels, :type, :string, :limit => 50, :null => false
  end
end
