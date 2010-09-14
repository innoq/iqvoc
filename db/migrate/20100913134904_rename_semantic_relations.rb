class RenameSemanticRelations < ActiveRecord::Migration
  def self.up
    rename_table :semantic_relations, :concept_relations
  end

  def self.down
    rename_table :concept_relations, :semantic_relations
  end
end
