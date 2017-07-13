require 'active_support/concern'

module Iqvoc
  module Configuration
    module Collection
      extend ActiveSupport::Concern

      included do
        Iqvoc.first_level_class_configuration_modules << self

        mattr_accessor :base_class_name, :member_class_name, :note_class_names, :include_module_names

        self.base_class_name = 'Collection::SKOS::Unordered'

        self.member_class_name  = 'Collection::Member::SKOS::Base'

        self.note_class_names = [ 'Note::SKOS::Definition' ]

        self.include_module_names = []
      end

      module ClassMethods
        def base_class
          base_class_name.constantize
        end

        def member_class
          member_class_name.constantize
        end

        def note_classes
          note_class_names.map(&:constantize)
        end

        def include_modules
          include_module_names.map(&:constantize)
        end
      end
    end
  end
end
