class Concept::Relation::SKOS::Narrower < Concept::Relation::Base

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
