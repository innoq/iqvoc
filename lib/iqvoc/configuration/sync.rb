require 'active_support/concern'

module Iqvoc
  module Configuration
    module Sync
      extend ActiveSupport::Concern

      included do
        mattr_accessor :syncable_class_names
        self.syncable_class_names = [Iqvoc::Concept.base_class_name]
      end

      module ClassMethods
        def syncable_classes
          self.syncable_class_names.map { |name| name.constantize }
        end
      end

    end
  end
end
