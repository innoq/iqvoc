class CreateSemanticRelations < ActiveRecord::Migration
  def self.up
    create_table :semantic_relations do |t|
      t.string  :uuid,   :limit => 36, :null => false
      t.string  :type,   :limit => 50, :null => false, :default => 'SemanticRelation'
      t.belongs_to :owner
      t.belongs_to :target

      t.timestamps
    end
  end

  def self.down
    drop_table :semantic_relations
  end
end
