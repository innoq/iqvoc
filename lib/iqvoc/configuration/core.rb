require 'active_support/concern'

module Iqvoc
  module Configuration
    module Core
      extend ActiveSupport::Concern

      included do
        mattr_accessor :searchable_class_names,
          :unlimited_search_results,
          :default_rdf_namespace_helper_methods,
          :rdf_namespaces,
          :change_note_class_name,
          :first_level_class_configuration_modules,
          :ability_class_name,
          :localized_routes,
          :core_assets

        self.localized_routes = [] # routing extensibility hook

        self.core_assets = %w(
          manifest.css
          manifest.js
          bootstrap/bootstrap.css
          bootstrap/bootstrap-responsive.css
          iqvoc/ie_fixes.css
          bootstrap/bootstrap.js
          html5.js
        )

        self.searchable_class_names = [
          'Labeling::SKOS::Base',
          'Labeling::SKOS::PrefLabel',
          'Note::Base'
        ]
        self.unlimited_search_results = false

        self.default_rdf_namespace_helper_methods = [:iqvoc_default_rdf_namespaces]

        self.rdf_namespaces = {
          :rdf  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          :rdfs => "http://www.w3.org/2000/01/rdf-schema#",
          :owl  => "http://www.w3.org/2002/07/owl#",
          :skos => "http://www.w3.org/2004/02/skos/core#",
          :dct  => "http://purl.org/dc/terms/",
          :foaf => "http://xmlns.com/foaf/spec/"
        }

        # The class to use for automatic generation of change notes on every save
        self.change_note_class_name = 'Note::SKOS::ChangeNote'

        self.first_level_class_configuration_modules = [] # Will be set in the modules

        self.ability_class_name = 'Iqvoc::Ability'

        # initialize
        self.config.register_settings({
          "title" => "iQvoc",
          "languages.pref_labeling" => ["en", "de"],
          "languages.further_labelings.Labeling::SKOS::AltLabel" => ["en", "de"],
          "note_languages" => ["en", "de"]
        })
      end

      module ClassMethods
        def generate_secret_token
          require 'securerandom'

          template = Rails.root.join("config", "initializers", "secret_token.rb.template")
          raise "File not found: #{template}" unless File.exist?(template)

          file_name = "config/initializers/secret_token.rb"

          token = SecureRandom.hex(64)
          txt = File.read(template)
          txt.gsub!("S-E-C-R-E-T", token)

          File.open(file_name, "w") do |f|
            f.write txt
          end

          puts "Secret token configuration has been created in #{file_name}."
        end

        # ************** instance configuration **************

        def config(&block)
          cfg = InstanceConfiguration.instance
          if block
            block.call(cfg)
          else
            return cfg
          end
        end

        def change_note_class
          change_note_class_name.constantize
        end

        def searchable_classes
          searchable_class_names.map(&:constantize)
        end

        def first_level_classes
          self.first_level_class_configuration_modules.map { |mod| mod.send(:base_class) }
        end

        def ability_class
          ability_class_name.constantize
        end

        def title
          return config["title"]
        end

        def note_languages
          return config["note_languages"]
        end

        def all_languages
          (Iqvoc::Concept.pref_labeling_languages + Iqvoc::Concept.further_labeling_class_names.values.flatten + note_languages).compact.map(&:to_s).uniq
        end

        # @deprecated
        def title=(value)
          ActiveSupport::Deprecation.warn "title has been moved into instance configuration", caller
          self.config.register_setting("title", value)
        end

      end

    end
  end
end
