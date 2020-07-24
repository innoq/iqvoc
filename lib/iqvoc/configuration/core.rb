require 'active_support/concern'

module Iqvoc
  module Configuration
    module Core
      extend ActiveSupport::Concern

      included do
        mattr_accessor :searchable_class_names,
          :unlimited_search_results,
          :default_rdf_namespace_helper_modules,
          :default_rdf_namespace_helper_methods,
          :rdf_namespaces,
          :change_note_class_name,
          :first_level_class_configuration_modules,
          :navigation_items,
          :ability_class_name,
          :localized_routes,
          :core_assets,
          :search_sections,
          :export_path,
          :upload_path,
          :truncation_blacklist,
          :host_namespace

        self.localized_routes = [] # routing extensibility hook

        self.core_assets = %w(
          manifest.css
          manifest.js
          iqvoc/ie_fixes.css
          html5shiv/dist/html5shiv.js
          *.png
          *.jpg
          *.jpeg
          *.gif
          *.svg
          *.ttf
          *.woff
          *.eof
        )

        self.navigation_items = [{
          text: 'Dashboard',
          href: proc { dashboard_path },
          controller: 'dashboard',
          :authorized? => proc { can? :use, :dashboard }
        }, {
          text: 'Scheme',
          href: proc { scheme_path },
          controller: 'concepts/scheme',
          :authorized? => proc { can? :read, Iqvoc::Concept.root_class.instance }
        }, {
          text: proc { ::Concept::Base.model_name.human(count: 2) },
          href: proc { hierarchical_concepts_path },
          controller: 'concepts/hierarchical',
          :active? => proc {
            %w(concepts/hierarchical concepts/alphabetical concepts/untranslated).
                include?(params[:controller])
          }
        }, {
          text: proc { t('txt.views.navigation.collections') },
          href: proc { collections_path },
          controller: 'collections'
        }, {
          text: proc { t('txt.views.navigation.search') },
          href: proc { search_path },
          controller: 'search_results'
        }, {
          text: proc { t('txt.views.navigation.help') },
          items: [{
            text: proc { t('txt.views.navigation.help') },
            href: proc { help_path },
            controller: 'pages',
            action: 'help',
            :authorized? => proc { can? :read, :help }
          }, {
            text: proc { t('txt.views.navigation.about') },
            href: 'http://iqvoc.net/'
          }, {
            text: proc { t('txt.views.navigation.version') },
            href: proc { version_path }
          }]
        }]

        self.searchable_class_names = {
          'Labeling::SKOS::Base' => 'labels',
          'Labeling::SKOS::PrefLabel' => 'pref_labels',
          'Note::Base' => 'notes'
        }

        self.unlimited_search_results = false

        self.default_rdf_namespace_helper_modules = []
        self.default_rdf_namespace_helper_methods = [:iqvoc_default_rdf_namespaces]

        self.rdf_namespaces = {
          rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
          rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
          owl: 'http://www.w3.org/2002/07/owl#',
          skos: 'http://www.w3.org/2004/02/skos/core#',
          dct: 'http://purl.org/dc/terms/',
          foaf: 'http://xmlns.com/foaf/spec/',
          void: 'http://rdfs.org/ns/void#',
          iqvoc: 'http://try.iqvoc.net/schema#'
        }

        # The class to use for automatic generation of change notes on every save
        self.change_note_class_name = 'Note::SKOS::ChangeNote'

        self.first_level_class_configuration_modules = [] # Will be set in the modules

        self.ability_class_name = 'Ability'

        self.search_sections = [
          'terms',
          'mode',
          'klass',
          'type',
          'collection',
          'languages',
          'change_note',
          'datasets'
        ]

        # ignored database tables during thesaurus truncation
        self.truncation_blacklist = [
          'schema_migrations',
          'users',
          'exports',
          'imports'
        ]

        # initialize
        self.config.register_settings({
          'title' => 'iQvoc',
          'languages.pref_labeling' => ['en', 'de'],
          'languages.further_labelings.Labeling::SKOS::AltLabel' => ['en', 'de'],
          'languages.notes' => ['en', 'de'],
          'performance.unbounded_hierarchy' => false,
          'sources.iqvoc' => ['']
        })
      end

      module ClassMethods
        # ************** instance configuration **************

        def config(&block)
          cfg = Iqvoc::Configuration::InstanceConfiguration.instance
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
          searchable_class_names.keys.map(&:constantize)
        end

        def first_level_classes
          self.first_level_class_configuration_modules.map { |mod| mod.send(:base_class) }
        end

        def ability_class
          ability_class_name.constantize
        end

        def title
          config['title']
        end

        def note_languages
          config['languages.notes']
        end

        # returns a list of all languages selectable for labels and/or notes
        def all_languages
          (Iqvoc::Concept.pref_labeling_languages +
              Iqvoc::Concept.further_labeling_class_names.values.flatten +
              note_languages).compact.map(&:to_s).uniq
        end

        # @deprecated
        def title=(value)
          ActiveSupport::Deprecation.warn 'title has been moved into instance configuration', caller
          self.config.register_setting('title', value)
        end

        def engine?
          Iqvoc.const_defined?(:Engine)
        end

        def root
          if engine?
            Iqvoc::Engine.root
          else
            Rails.root
          end
        end

        def routing_constraint
          lambda do |params, req|
            langs = Iqvoc::Concept.pref_labeling_languages.join('|').presence || 'en'
            return params[:lang].to_s =~ /^#{langs}$/
          end
        end

        def host_version
          if Iqvoc.host_namespace
            Iqvoc.host_namespace::VERSION
          end
        end
      end
    end
  end
end
