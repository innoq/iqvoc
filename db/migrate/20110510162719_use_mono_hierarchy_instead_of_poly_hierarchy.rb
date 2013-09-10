class UseMonoHierarchyInsteadOfPolyHierarchy < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      execute "UPDATE concept_relations SET type = 'Concept::Relation::SKOS::Broader::Mono' WHERE type = 'Concept::Relation::SKOS::Broader::Poly'"
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      execute "UPDATE concept_relations SET type = 'Concept::Relation::SKOS::Broader::Poly' WHERE type = 'Concept::Relation::SKOS::Broader::Mono'"
    end
  end
end
