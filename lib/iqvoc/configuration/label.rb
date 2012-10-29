require 'active_support/concern'

module Iqvoc
  module Configuration
    module Label
      extend ActiveSupport::Concern

      included do
        mattr_accessor :base_class_name
        self.base_class_name        = 'Label::SKOS::Base'
      end

      module ClassMethods
        # Do not use the following method in models. This will probably cause a
        # loading loop (something like "expected file xyz to load ...")
        def base_class
          base_class_name.constantize
        end
      end

    end
  end
end
