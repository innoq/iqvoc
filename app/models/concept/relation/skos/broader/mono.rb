class Concept::Relation::SKOS::Broader::Mono < Concept::Relation::SKOS::Broader::Base

  def self.only_one_allowed?
    true
  end

end
