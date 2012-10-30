require 'active_support/concern'

module Iqvoc
  module Configuration
    module Sync
      extend ActiveSupport::Concern

      included do
        mattr_accessor :syncable_class_names
        self.syncable_class_names = [Iqvoc::Concept.base_class_name]

        Iqvoc.config.register_settings({
          "triplestore_url" => "http://example.org:8080",
          "triplestore_username" => "",
          "triplestore_password" => "",
          "triplestore_autosync" => false
        })
      end

      module ClassMethods
        def syncable_classes
          self.syncable_class_names.map { |name| name.constantize }
        end
      end

    end
  end
end
