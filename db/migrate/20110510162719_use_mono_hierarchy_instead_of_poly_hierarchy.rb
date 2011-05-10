class UseMonoHierarchyInsteadOfPolyHierarchy < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      Concept::Relation::Base.update_all("type = 'Concept::Relation::SKOS::Broader::Mono'", :type => 'Concept::Relation::SKOS::Broader::Poly')
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      Concept::Relation::Base.update_all("type = 'Concept::Relation::SKOS::Broader::Poly'", :type => 'Concept::Relation::SKOS::Broader::Mono')
    end
  end
end
