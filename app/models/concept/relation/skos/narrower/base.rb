class Concept::Relation::SKOS::Narrower::Base < Concept::Relation::SKOS::Base

  self.rdf_predicate = 'narrower'

  def self.reverse_relation_class
    Iqvoc::Concept.broader_relation_class
  end

  def self.view_section(obj)
    "main"
  end

  def self.view_section_sort_key(obj)
    150
  end

  def self.partial_name(obj)
    "partials/concept/relation/skos/narrower"
  end

end
