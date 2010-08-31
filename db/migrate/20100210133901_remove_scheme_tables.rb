class RemoveSchemeTables < ActiveRecord::Migration
  def self.up
    drop_table :concept_schemes
    drop_table :concept_scheme_relations
  end

  def self.down
  end
end
