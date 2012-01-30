require "active_support/concern"

module Iqvoc
  module Configuration
    module Collection
      extend ActiveSupport::Concern
      
      included do
        mattr_accessor :base_class_name

        self.base_class_name = 'Collection::Unordered'
      end
      
      module ClassMethods
        def base_class
          base_class_name.constantize
        end
      end

    end
  end
end