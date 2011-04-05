class Labeling::SKOS::PrefLabel < Labeling::SKOS::Base

  self.rdf_predicate = 'prefLabel'

  def self.only_one_allowed?
    true
  end
 
end