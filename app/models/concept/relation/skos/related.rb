class Concept::Relation::SKOS::Related < Concept::Relation::Base

  def build_rdf(document, subject)
    subject.Skos.related(IqRdf.build_uri(target.origin))
  end

end
