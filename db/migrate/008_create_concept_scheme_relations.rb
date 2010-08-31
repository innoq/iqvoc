class CreateConceptSchemeRelations < ActiveRecord::Migration
  def self.up
    create_table :concept_scheme_relations do |t|
      t.integer :top_concept_id
      t.integer :in_scheme_id

      t.timestamps
    end
  end

  def self.down
    drop_table :concept_scheme_relations
  end
end
