class AddTypeToLabelRelation < ActiveRecord::Migration
  def self.up
    add_column :label_relations, :type, :string
  end

  def self.down
    remove_column :label_relations, :type
  end
end
