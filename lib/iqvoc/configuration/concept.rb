require "active_support/concern"

module Iqvoc
  module Configuration
    module Concept
      extend ActiveSupport::Concern
      
      included do
        Iqvoc.first_level_class_configuration_modules << self

        mattr_accessor :base_class_name,
        :broader_relation_class_name, :further_relation_class_names,
        :pref_labeling_class_name,
        :match_class_names,
        :note_class_names,
        :additional_association_class_names,
        :view_sections,
        :include_module_names

        self.base_class_name              = 'Concept::SKOS::Base'

        self.broader_relation_class_name  = 'Concept::Relation::SKOS::Broader::Mono'
        self.further_relation_class_names = [ 'Concept::Relation::SKOS::Related' ]

        self.pref_labeling_class_name     = 'Labeling::SKOS::PrefLabel'

        self.note_class_names             = [
          Iqvoc.change_note_class_name,
          'Note::SKOS::Definition',
          'Note::SKOS::EditorialNote',
          'Note::SKOS::Example',
          'Note::SKOS::HistoryNote',
          'Note::SKOS::ScopeNote'
        ]

        self.match_class_names            = [
          'Match::SKOS::CloseMatch',
          'Match::SKOS::ExactMatch',
          'Match::SKOS::RelatedMatch',
          'Match::SKOS::BroadMatch',
          'Match::SKOS::NarrowMatch',
        ]

        self.additional_association_class_names = {}

        self.view_sections = ["main", "labels", "relations", "notes", "matches"]

        self.include_module_names = []
      end
      
      module ClassMethods
        def pref_labeling_languages
          # FIXME: mutable object; needs custom array setters to guard against
          # modification (to highlight deprecated usage)
          return Iqvoc.config["languages.pref_labeling"]
        end

        # Do not use the following method in models. This will probably cause a
        # loading loop (something like "expected file xyz to load ...")
        def base_class
          base_class_name.constantize
        end

        def pref_labeling_class
          pref_labeling_class_name.constantize
        end

        def labeling_class_names
          { pref_labeling_class_name => pref_labeling_languages }.merge(further_labeling_class_names)
        end

        def labeling_classes
          { pref_labeling_class => pref_labeling_languages }.merge(further_labeling_classes)
        end

        def broader_relation_class
          broader_relation_class_name.constantize
        end

        # returns hash of class name / languages pairs
        # e.g. { "Labeling::SKOS::AltLabel" => ["de", "en"] }
        def further_labeling_class_names
          # FIXME: mutable object; needs custom hash setters to guard against
          # modification of languages arrays (to highlight deprecated usage)
          return Iqvoc.config.defaults.each_with_object({}) do |(key, default_value), hsh|
            prefix = "languages.further_labelings."
            if key.start_with? prefix
              class_name = key[prefix.length..-1]
              hsh[class_name] = Iqvoc.config[key]
            end
          end
        end

        def further_labeling_classes
          further_labeling_class_names.keys.each_with_object({}) do |class_name, hash|
            hash[class_name.constantize] = further_labeling_class_names[class_name]
          end
        end

        def relation_class_names
          further_relation_class_names + [broader_relation_class_name, broader_relation_class.narrower_class.name]
        end

        def relation_classes
          relation_class_names.map(&:constantize)
        end

        def further_relation_classes
          further_relation_class_names.map(&:constantize)
        end

        def note_classes
          note_class_names.map(&:constantize)
        end

        def match_classes
          match_class_names.map(&:constantize)
        end

        def additional_association_classes
          additional_association_class_names.keys.each_with_object({}) do |class_name, hash|
            hash[class_name.constantize] = additional_association_class_names[class_name]
          end
        end

        def supports_multi_language_pref_labelings?
          pref_labeling_languages.size > 1
        end

        def include_modules
          include_module_names.map(&:constantize)
        end
      
        # @deprecated
        def pref_labeling_languages=(value)
          ActiveSupport::Deprecation.warn "pref_labeling_languages has been moved into instance configuration", caller
          Iqvoc.config.register_setting("languages.pref_labeling", arr)
        end

        # @deprecated
        def further_labeling_class_names=(hsh)
          ActiveSupport::Deprecation.warn "further_labeling_class_names has been moved into instance configuration", caller
          prefix = "languages.further_labelings."
          hsh.each do |class_name, value|
            Iqvoc.config.register_setting(prefix + class_name, value.map(&:to_s))
          end
        end
      end

    end
  end
end