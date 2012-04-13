require "active_support/concern"

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
          :navigation_items,
          :core_assets

        self.navigation_items = [
          {
            :content => proc { link_to "Dashboard", dashboard_path },
            :controller => "dashboard",
            :authorized? => proc { can? :use, :dashboard }
          }, {
            :content => proc { link_to ::Concept::Base.model_name.human(:count => 2),
                hierarchical_concepts_path },
            :controller => "concepts/hierarchical"
          }, {
            :content => proc { link_to t("txt.views.navigation.collections"),
                collections_path },
            :controller => "collections"
          }, {
            :content => proc { link_to t("txt.views.navigation.search"), search_path },
            :controller => "search_results"
          }, {
            :content => proc { link_to t("txt.views.navigation.users"), users_path },
            :controller => "users",
            :authorized? => proc { can? :manage, User }
          }, {
            :content => proc { link_to t("txt.views.navigation.instance_configuration"),
                instance_configuration_path },
            :controller => "instance_configuration",
            :authorized? => proc { can? :manage, Iqvoc.config }
          }, {
            :content => proc { link_to t("txt.views.navigation.about"), "http://iqvoc.net/" },
            :active? => false
          }
        ]

        self.core_assets = %w(
          manifest.css
          manifest.js
          bootstrap/bootstrap.css
          bootstrap/bootstrap-responsive.css
          iqvoc/ie_fixes.css
          excanvas.js
          jit_rgraph.js
          iqvoc/visualization.js
          json2.js
          bootstrap/bootstrap.js
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
          :dct  => "http://purl.org/dc/terms/"
        }

        # The class to use for automatic generation of change notes on every save
        self.change_note_class_name = 'Note::SKOS::ChangeNote'

        self.first_level_class_configuration_modules = [] # Will be set in the modules

        self.ability_class_name = 'Iqvoc::Ability'

        # initialize
        self.config.register_settings({
          "title" => "iQvoc",
          "available_languages" => ["en", "de"],
          "languages.pref_labeling" => ["en", "de"],
          "languages.further_labelings.Labeling::SKOS::AltLabel" => ["en", "de"]
        })
        self.config.initialize_cache
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

        def available_languages
          return config["available_languages"]
        end

        # @deprecated
        def title=(value)
          ActiveSupport::Deprecation.warn "title has been moved into instance configuration", caller
          self.config.register_setting("title", value)
        end

        # @deprecated
        def available_languages=(value)
          ActiveSupport::Deprecation.warn "available_languages has been moved into instance configuration", caller
          self.config.register_setting("available_languages", value)
        end
      end

    end
  end
end
