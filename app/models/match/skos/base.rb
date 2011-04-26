class Match::SKOS::Base < Match::Base
  
  self.rdf_namespace = 'skos'

  def self.build_from_rdf(subject, predicate, object)
    raise "Note::SKOS::Base#build_from_rdf: Subject (#{subject}) must be able to recieve this kind of notes (#{self.name} => #{self.name.to_relation_name})." unless subject.class.reflections.include?(self.name.to_relation_name)
    raise "Note::SKOS::Base#build_from_rdf: Object (#{object}) must be a URI" unless object =~ /^<(.+)>$/
    uri = $1

    subject.send(self.name.to_relation_name) << self.new(:value => uri)
  end

  def build_rdf(document, subject)
    raise "Match::SKOS::Base#build_rdf: Class #{self.name} needs to define self.rdf_namespace and self.rdf_predicate." unless self.rdf_namespace && self.rdf_predicate
 
    if (IqRdf::Namespace.find_namespace_class(self.rdf_namespace.camelcase))
      subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, URI.parse(value))
    else
      raise "Match::SKOS::MappingRelation#build_rdf: couldn't find Namespace '#{self.rdf_namespace.camelcase}'."
    end
  end

end