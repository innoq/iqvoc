class CreateIndices < ActiveRecord::Migration
  def self.up
    add_index :concepts, [:origin]
    add_index :labels, [:owner_id, :language]
    add_index :notes, [:owner_id, :language]
    add_index :semantic_relations, [:owner_id, :target_id]
    add_index :semantic_relations, [:target_id]
  end

  def self.down
    remove_index :concepts, :column => [:origin] rescue nil
    remove_index :labels, :column => [:owner_id, :language] rescue nil
    remove_index :notes, :column => [:owner_id, :language] rescue nil
    remove_index :semantic_relations, :column => [:owner_id, :target_id] rescue nil
    remove_index :semantic_relations, :column => [:target_id] rescue nil
  end
end
