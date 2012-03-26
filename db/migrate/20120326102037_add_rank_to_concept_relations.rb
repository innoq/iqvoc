class AddRankToConceptRelations < ActiveRecord::Migration
  def change
    add_column :concept_relations, :rank, :integer, :default => 100
  end
end
