class Note::SKOS::Base < Note::Base

  self.rdf_namespace = 'skos'

  def self.build_from_rdf(subject, predicate, object)
    raise "Note::SKOS::Base#build_from_rdf: Subject (#{subject}) must be able to recieve this kind of notes (#{self.name} => #{self.name.to_relation_name})." unless subject.class.reflections.include?(self.name.to_relation_name)
    raise "Note::SKOS::Base#build_from_rdf: Object (#{object}) must be a string literal" unless object =~ /^"(.+)"(@(.+))$/
    value = $1
    lang = $3

    subject.send(self.name.to_relation_name) << self.new(:value => value, :language => lang)
  end

  def build_rdf(document, subject)
    ns, id = "", ""
    if (self.rdf_namespace && self.rdf_predicate)
      ns, id = self.rdf_namespace, self.rdf_predicate
    elsif self.class == Note::SKOS::Base # This could be done by setting self.rdf_predicate to 'note'. But all subclasses would inherit this value.
      ns, id = "Skos", "note"
    else
      raise "Note::SKOS::Base#build_rdf: Class #{self.name} needs to define self.rdf_namespace and self.rdf_predicate."
    end

    if (IqRdf::Namespace.find_namespace_class(ns))
      subject.send(ns).send(id, value, :lang => language)
    else
      raise "Note::SKOS::Base#build_rdf: couldn't find Namespace '#{ns}'."
    end
  end

end
