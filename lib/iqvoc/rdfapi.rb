module Iqvoc
  module RDFAPI

    OBJECT_DICTIONARY = Iqvoc::SkosImporter::FIRST_LEVEL_OBJECT_CLASSES.inject({}) do |hash, klass|
      hash["#{klass.rdf_namespace}:#{klass.rdf_class}"] = klass
      hash
    end

    PREDICATE_DICTIONARY = Iqvoc::SkosImporter::SECOND_LEVEL_OBJECT_CLASSES.inject({}) do |hash, klass|
      hash["#{klass.rdf_namespace}:#{klass.rdf_predicate}"] = klass
      hash
    end

    def self.devour(rdf_subject, rdf_predicate, rdf_object)
      case rdf_predicate
      when 'a', 'rdf:type'
        case rdf_object
        when String
          target = OBJECT_DICTIONARY[rdf_object] || rdf_object.constantize
        else
          target = rdf_object
        end
        target.find_or_initialize_by_origin(rdf_subject)
      when String
        # dictionary lookup
        target = PREDICATE_DICTIONARY[rdf_predicate] || rdf_predicate.constantize
        target.build_from_rdf(rdf_subject, target, rdf_object)
      else # is a class
        rdf_predicate.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
      end
    end

  end
end
