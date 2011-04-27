class Concept::SKOS::Base < Concept::Base

  self.rdf_namespace = "skos"
  self.rdf_class = "Concept"

  def build_rdf_subject(document, controller, &block)
    ns = IqRdf::Namespace.find_namespace_class(self.rdf_namespace.to_sym)
    raise "Namespace '#{rdf_namespace}' is not defined in IqRdf document." unless ns
    IqRdf.build_uri(self.origin, ns.build_uri(self.rdf_class), &block)
  end

end
