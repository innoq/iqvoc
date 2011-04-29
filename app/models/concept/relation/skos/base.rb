class Concept::Relation::SKOS::Base < Concept::Relation::Base

  self.rdf_namespace = 'skos'

  def self.build_from_rdf(subject, predicate, object)
    raise "Labeling::SKOS::Base#build_from_rdf: Subject (#{subject}) must be a Concept." unless subject.is_a?(Concept::Base)
    raise "Labeling::SKOS::Base#build_from_rdf: Object (#{object}) must be a Concept." unless object.is_a?(Concept::Base)

    if subject.send(self.name.to_relation_name).select{|rel| rel.target_id == object.id || rel.target == object}.empty?
      subject.send(self.name.to_relation_name) << self.new(:target => object)
    end
    if self.reverse_relation_class && object.send(self.reverse_relation_class.name.to_relation_name).select{|rel| rel.target_id == subject.id || rel.target == subject}.empty?
      object.send(self.reverse_relation_class.name.to_relation_name) << self.reverse_relation_class.new(:target => subject)
    end
  end

  def build_rdf(document, subject)
    subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, IqRdf.build_uri(target.origin))
  end

end
