class RemoveNullRequirements < ActiveRecord::Migration
  def self.up
    change_column :concepts, :type, :string, :null => true
    change_column :concept_relations, :type, :string, :null => true
    change_column :labels, :language, :string, :null => true
    change_column :notes, :owner_type, :string, :null => false
  end

  def self.down
  end
end
