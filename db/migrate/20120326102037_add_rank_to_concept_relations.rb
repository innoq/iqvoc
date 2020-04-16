class AddRankToConceptRelations < ActiveRecord::Migration[4.2]
  def change
    add_column :concept_relations, :rank, :integer, default: 100
  end
end
