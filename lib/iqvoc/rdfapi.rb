module Iqvoc
  module RDFAPI
    FIRST_LEVEL_OBJECT_CLASSES  = [Iqvoc::Concept.base_class, Iqvoc::Collection.base_class]
    SECOND_LEVEL_OBJECT_CLASSES = Iqvoc::Concept.labeling_classes.keys +
                                  Iqvoc::Concept.note_classes +
                                  Iqvoc::Concept.relation_classes +
                                  Iqvoc::Concept.match_classes +
                                  Iqvoc::Collection.member_classes


    OBJECT_DICTIONARY = FIRST_LEVEL_OBJECT_CLASSES.inject({}) do |hash, klass|
      hash["#{klass.rdf_namespace}:#{klass.rdf_class}"] = klass
      hash
    end

    PREDICATE_DICTIONARY = SECOND_LEVEL_OBJECT_CLASSES.inject({}) do |hash, klass|
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
