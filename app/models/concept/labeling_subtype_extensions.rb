module Concept
  module LabelingSubtypeExtensions
    def for_class(labeling_class)
      load_association_if_empty
      proxy_association.target.select{|assoc| assoc.type.to_s == labeling_class.to_s}
    end

    def for_rdf_class(rdf_class)
      load_association_if_empty
      proxy_association.target.select{|assoc| assoc.implements_rdf? rdf_class}
    end

    protected

    def load_association_if_empty
      if proxy_association.target.empty?
        proxy_association.target = proxy_association.owner.labelings.includes(:target).all
      end
    end

  end
end
