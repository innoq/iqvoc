module ActsAsRdfClass
  extend ActiveSupport::Concern
  include ActsAsRdfThing

  included do
    class_attribute :rdf_namespace, :rdf_class
    self.rdf_namespace = nil
    self.rdf_class     = nil
  end

  module ClassMethods
    def acts_as_rdf_class(str)
      self.rdf_internal_name = str
      self.rdf_namespace, self.rdf_class = str.split(':', 2)
    end

    def relation_name
      "#{self.rdf_namespace}_#{self.rdf_class}".underscore
    end
  end
end

