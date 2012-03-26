require 'active_support/concern'

module Iqvoc
  module Rankable
    extend ActiveSupport::Concern

    module ClassMethods
      def rankable?
        true
      end
    end

  end
end
