class Concept::Relation::SKOS::Narrower < Concept::Relation::Base

  def self.view_section
    "main"
  end

  def self.view_section_sort_key
    150
  end

  def self.partial_name
    "partials/concept/relation/skos/narrower"
  end

end
