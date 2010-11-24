class Note::SKOS::Base < Note::Base

  def build_rdf(document, subject)
    ns, id = "", ""
    if self.class == Note::SKOS::Base
      ns, id = "Skos", "note"
    else # we're in a subclass. So let's try it the generic way:
      mod = self.class.name.split("::")
      ns, id = mod[-2].underscore.camelcase, mod[-1].underscore.camelcase(:lower)
    end

    if (IqRdf::Namespace.find_namespace_class(ns))
      subject.send(ns).send(id, value, :lang => language)
    else
      raise "Note::SKOS::Base#build_rdf: couldn't find Namespace '#{ns}'."
    end
  end

end
