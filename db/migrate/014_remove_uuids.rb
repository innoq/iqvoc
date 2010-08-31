class RemoveUuids < ActiveRecord::Migration
  def self.up
    remove_column :concepts, :uuid
    remove_column :concept_schemes, :uuid
    remove_column :semantic_relations, :uuid
  end

  def self.down
    # add_column :concepts, :uuid, :string, :limit => 36
    # add_column :concept_schemes, :uuid, :string, :limit => 36
    # add_column :semantic_relations, :uuid, :limit => 36, :null => false
  end
end
