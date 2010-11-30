class Concept::SKOS::Base < Concept::Base

  def build_rdf_subject(document, controller, &block)
    IqRdf.build_uri(self.origin, IqRdf::Skos::build_uri("Concept"), &block)
  end

end
