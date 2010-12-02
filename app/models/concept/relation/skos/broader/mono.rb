class Concept::Relation::SKOS::Broader::Mono < Concept::Relation::SKOS::Broader::Base

  def self.partial_name(obj)
    "partials/concept/relation/skos/broader/mono"
  end

  def self.only_one_allowed?
    true
  end

end
