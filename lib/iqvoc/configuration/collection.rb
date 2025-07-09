require 'active_support/concern'

module Iqvoc
  module Configuration
    module Collection
      extend ActiveSupport::Concern

      included do
        Iqvoc.first_level_class_configuration_modules << self

        mattr_accessor :base_class_name, :member_class_name, :note_class_names, :include_module_names,
                       :pref_labeling_class_name, :alt_labeling_class_name, :hidden_labeling_class_name

        self.base_class_name = 'Collection::Skos::Unordered'
        self.member_class_name  = 'Collection::Member::Skos::Base'

        self.note_class_names = [ 'Note::Skos::Definition' ]

        self.pref_labeling_class_name     = 'Labeling::Skos::PrefLabel'
        self.alt_labeling_class_name      = 'Labeling::Skos::AltLabel'
        self.hidden_labeling_class_name   = 'Labeling::Skos::HiddenLabel'

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

        def pref_labeling_class
          pref_labeling_class_name.constantize
        end

        def alt_labeling_class
          alt_labeling_class_name.constantize
        end

        def include_modules
          include_module_names.map(&:constantize)
        end
      end
    end
  end
end
