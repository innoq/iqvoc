class Match::SKOS::MappingRelation < Match::Base
  
  def build_rdf(document, subject)
    # Let's try it the generic way:
    mod = self.class.name.split("::")
    ns, id = mod[-2].underscore.camelcase, mod[-1].underscore.camelcase(:lower)

    if (IqRdf::Namespace.find_namespace_class(ns))
      subject.send(ns).send(id, URI.parse(value))
    else
      raise "Match::SKOS::MappingRelation#build_rdf: couldn't find Namespace '#{ns}'."
    end
  end

end
