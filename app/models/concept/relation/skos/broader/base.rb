class Concept::Relation::SKOS::Broader::Base < Concept::Relation::Base

  def self.narrower_class
    Concept::Relation::SKOS::Narrower
  end

  def self.view_section
    "main"
  end

  def self.view_section_sort_key
    100
  end

  def self.partial_name
    "partials/concept/relation/skos/broader"
  end

end
