require 'active_support/concern'

module Iqvoc
  module Rankable
    extend ActiveSupport::Concern

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
