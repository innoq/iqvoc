# encoding: UTF-8

module Concept
  module TypedHasManyExtension

    def for_class(klass)
      load_association_if_empty
      proxy_association.target.select{|assoc| assoc.type.to_s == klass.to_s}
    end

    def for_rdf_class(rdf_class)
      load_association_if_empty
      proxy_association.target.select{|assoc| assoc.implements_rdf? rdf_class}
    end

    protected

    def load_association_if_empty
      if proxy_association.target.empty?
        proxy_association.target = proxy_association.owner.relations.all
      end
    end

  end
end

