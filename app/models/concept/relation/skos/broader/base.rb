class Concept::Relation::SKOS::Broader::Base < Concept::Relation::Base

  def self.narrower_class
    Concept::Relation::SKOS::Narrower
  end

  def self.view_section(obj)
    "main"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/concept/relation/skos/broader"
  end

end
