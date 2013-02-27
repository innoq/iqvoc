module ActsAsRdfPredicate
  extend ActiveSupport::Concern
  include ActsAsRdfThing

  included do
    class_attribute :rdf_namespace, :rdf_predicate
    self.rdf_namespace = nil
    self.rdf_predicate = nil
  end

  module ClassMethods
    def acts_as_rdf_predicate(str)
      self.rdf_internal_name = str
      self.rdf_namespace, self.rdf_predicate = str.split(':', 2)
    end

    def relation_name
      "#{self.rdf_namespace}_#{self.rdf_predicate}".underscore
    end
  end

end
