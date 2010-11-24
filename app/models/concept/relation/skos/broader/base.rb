class Concept::Relation::SKOS::Broader::Base < Concept::Relation::Base

  def build_rdf(document, subject)
    subject.Skos.broader(IqRdf.build_uri(target.origin))
  end

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

  def self.partial_name(obj)
    "partials/concept/relation/skos/broader"
  end

  def self.narrower_editable
    !only_one_allowed?
  end

end
