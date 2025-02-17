class UseMonoHierarchyInsteadOfPolyHierarchy < ActiveRecord::Migration[4.2]
  def self.up
    ActiveRecord::Base.transaction do
      execute "UPDATE concept_relations SET type = 'Concept::Relation::Skos::Broader::Mono' WHERE type = 'Concept::Relation::Skos::Broader::Poly'"
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      execute "UPDATE concept_relations SET type = 'Concept::Relation::Skos::Broader::Poly' WHERE type = 'Concept::Relation::Skos::Broader::Mono'"
    end
  end
end
