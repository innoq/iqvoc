class Concept::Relation::SKOS::Broader::Base < Concept::Relation::SKOS::Base

  self.rdf_predicate = 'broader'

  def self.narrower_class
    Concept::Relation::SKOS::Narrower::Base
  end

  def self.reverse_relation_class
    self.narrower_class
  end

  def self.view_section(obj)
    "main"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.narrower_editable
    !only_one_allowed?
  end

end
