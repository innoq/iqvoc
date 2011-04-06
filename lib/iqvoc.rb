require 'string'

module Iqvoc

  require File.join(File.dirname(__FILE__), '../config/engine') unless Iqvoc.const_defined?(:Application)

  mattr_accessor :title,
    :searchable_class_names,
    :available_languages,
    :ability_class_name,
    :default_rdf_namespace_helper_methods,
    :change_note_class_name,
    :rdf_namespaces

  self.searchable_class_names = [
    'Labeling::SKOS::Base',
    'Labeling::SKOS::PrefLabel',
    'Note::Base' ]

  self.available_languages = [:de, :en]

  self.ability_class_name = "::Ability"

  self.default_rdf_namespace_helper_methods = [:iqvoc_default_rdf_namespaces]

  self.rdf_namespaces = {
    :rdf        => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    :rdfs       => "http://www.w3.org/2000/01/rdf-schema#",
    :owl        => "http://www.w3.org/2002/07/owl#",
    :skos       => "http://www.w3.org/2004/02/skos/core#",
  }

  # The class to use for automatic generation of change notes on every save
  self.change_note_class_name = 'Note::SKOS::ChangeNote'

  def self.ability_class
    ability_class_name.constantize
  end

  def self.change_note_class
    change_note_class_name.constantize
  end

  module Concept
    mattr_accessor :base_class_name,
      :broader_relation_class_name, :further_relation_class_names,
      :pref_labeling_class_name, :pref_labeling_languages, :further_labeling_class_names,
      :match_class_names,
      :note_class_names,
      :additional_association_class_names,
      :view_sections

    self.base_class_name              = 'Concept::SKOS::Base'

    self.broader_relation_class_name  = 'Concept::Relation::SKOS::Broader::Poly'
    self.further_relation_class_names = [ 'Concept::Relation::SKOS::Related' ]

    self.pref_labeling_class_name     = 'Labeling::SKOS::PrefLabel'
    self.pref_labeling_languages      = [ :en ]
    self.further_labeling_class_names = { 'Labeling::SKOS::AltLabel' => [ :de, :en ] }

    self.note_class_names             = [
      Iqvoc.change_note_class_name,
      'Note::SKOS::Definition',
      'Note::SKOS::EditorialNote',
      'Note::SKOS::Example',
      'Note::SKOS::HistoryNote',
      'Note::SKOS::ScopeNote' ]

    self.match_class_names            = [
      'Match::SKOS::CloseMatch',
      'Match::SKOS::ExactMatch',
      'Match::SKOS::RelatedMatch',
      'Match::SKOS::BroadMatch',
      'Match::SKOS::NarrowMatch',
    ]

    self.additional_association_class_names = {}

    self.view_sections = ["main", "labels", "relations", "notes", "matches"]

    # Do not use the following method in models. This will propably cause a
    # loading loop (something like "expected file xyz to load ...")
    def self.base_class
      base_class_name.constantize
    end

    def self.pref_labeling_class
      pref_labeling_class_name.constantize
    end

    def self.labeling_class_names
      further_labeling_class_names.merge(pref_labeling_class_name => pref_labeling_languages)
    end

    def self.labeling_classes
      further_labeling_classes.merge(pref_labeling_class => pref_labeling_languages)
    end

    def self.broader_relation_class
      broader_relation_class_name.constantize
    end

    def self.further_labeling_classes
      further_labeling_class_names.keys.each_with_object({}) do |class_name, hash|
        hash[class_name.constantize] = further_labeling_class_names[class_name]
      end
    end

    def self.relation_class_names
      further_relation_class_names + [broader_relation_class_name, broader_relation_class.narrower_class.name]
    end

    def self.relation_classes
      relation_class_names.map(&:constantize)
    end

    def self.further_relation_classes
      further_relation_class_names.map(&:constantize)
    end

    def self.note_classes
      note_class_names.map(&:constantize)
    end

    def self.match_classes
      match_class_names.map(&:constantize)
    end

    def self.additional_association_classes
      additional_association_class_names.keys.each_with_object({}) do |class_name, hash|
        hash[class_name.constantize] = additional_association_class_names[class_name]
      end
    end

    def self.supports_multi_language_pref_labelings?
      pref_labeling_languages.size > 1
    end

  end

  module Collection
    mattr_accessor :base_class_name

    self.base_class_name = 'Collection::Unordered'

    def self.base_class
      base_class_name.constantize
    end
  end

  module Label # This are the settings when using SKOS
    mattr_accessor :base_class_name

    self.base_class_name        = 'Label::SKOS::Base'

    # Do not use the following method in models. This will propably cause a
    # loading loop (something like "expected file xyz to load ...")
    def self.base_class
      base_class_name.constantize
    end

  end

  def self.searchable_classes
    searchable_class_names.map(&:constantize)
  end

end

# FIXME: For yet unknown reasons, the load hook gets to run 2 times
ActiveSupport.run_load_hooks(:after_iqvoc_config, Iqvoc)
