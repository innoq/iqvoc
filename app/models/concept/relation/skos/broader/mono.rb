class Concept::Relation::SKOS::Broader::Mono < ConceptRelation::SKOS::Broader::Base

  def self.only_one_allowed?
    true
  end

end
