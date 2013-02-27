module ActsAsRdfThing
  extend ActiveSupport::Concern

  included do
    class_attribute :rdf_internal_name
    self.rdf_internal_name = nil
  end

  def implements_rdf?(rdf_name = nil)
    if rdf_name
      self.rdf_internal_name == rdf_name
    else
      not rdf_internal_name.blank?
    end
  end
end
