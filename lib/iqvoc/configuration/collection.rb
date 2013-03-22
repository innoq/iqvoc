require 'active_support/concern'

module Iqvoc
  module Configuration
    module Collection
      extend ActiveSupport::Concern

      included do
        mattr_accessor :base_class_name, :member_class_name

        self.base_class_name = 'Collection::SKOS::Unordered'

        self.member_class_name  = 'Collection::Member::SKOS::Base'
      end

      module ClassMethods
        def base_class
          base_class_name.constantize
        end

        def member_class
          member_class_name.constantize
        end
      end

    end
  end
end
