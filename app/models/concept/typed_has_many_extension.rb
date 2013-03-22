# encoding: UTF-8

module Concept
  module TypedHasManyExtension

    def for_class(klass)
      load_target.select{|assoc| assoc.type.to_s == klass.to_s}
    end

    def for_rdf_class(rdf_class)
      load_target.select{|assoc| assoc.implements_rdf? rdf_class}
    end

  end
end

