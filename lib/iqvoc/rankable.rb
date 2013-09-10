require 'active_support/concern'

module Iqvoc
  module Rankable
    extend ActiveSupport::Concern

    def build_rdf(document, subject, suppress_extra_labels = false)
      super
      if self.class.rankable?
        predicate = "ranked#{rdf_predicate.titleize}"

        subject.Schema.build_predicate(predicate) do |blank_node|
          blank_node.Schema.relationWeight(rank)
          blank_node.Schema.relationTarget(IqRdf.build_uri(target.origin))
        end
      end
    end

    module ClassMethods
      def rankable?
        true
      end

      def partial_name(obj)
        'partials/concept/relation/ranked'
      end

      def edit_partial_name(obj)
        'partials/concept/relation/edit_ranked'
      end
    end

  end
end
