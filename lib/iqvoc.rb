# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'string'
require 'iqvoc/instance_configuration'

module Iqvoc

  unless Iqvoc.const_defined?(:Application)
    require File.join(File.dirname(__FILE__), '../config/engine')
  end

  mattr_accessor :searchable_class_names,
    :unlimited_search_results,
    :default_rdf_namespace_helper_methods,
    :rdf_namespaces,
    :change_note_class_name,
    :first_level_class_configuration_modules,
    :ability_class_name,
    :core_assets

  self.core_assets = %w(
    manifest.css
    manifest.js
    blueprint/screen.css
    blueprint/print.css
    blueprint/ie.css
    iqvoc/ie_fixes.css
    excanvas.js
    jit_rgraph.js
    iqvoc/visualization.js
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

  def self.change_note_class
    change_note_class_name.constantize
  end

  def self.searchable_classes
    searchable_class_names.map(&:constantize)
  end

  def self.first_level_classes
    self.first_level_class_configuration_modules.map { |mod| mod.send(:base_class) }
  end

  def self.ability_class
    ability_class_name.constantize
  end

  def self.generate_secret_token
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

  # ************** default instance configuration **************

  Rails.application.config.to_prepare do
    InstanceConfiguration::Defaults.merge!({
      "title" => "iQvoc",
      "available_languages" => ["en", "de"],
      "languages.pref_labeling" => ["en", "de"],
      "languages.further_labelings.Labeling::SKOS::AltLabel" => ["en", "de"]
    })
    InstanceConfiguration.instance.cache_settings # FIXME: does not take into account engines (=> re-cache when Defaults are modified?)
  end

  def self.title
    return InstanceConfiguration.instance["title"]
  end

  def self.available_languages
    return InstanceConfiguration.instance["available_languages"]
  end

  # ************** Concept specific settings **************

  module Concept

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

    def self.pref_labeling_languages
      return InstanceConfiguration.instance["languages.pref_labeling"]
    end

    # Do not use the following method in models. This will probably cause a
    # loading loop (something like "expected file xyz to load ...")
    def self.base_class
      base_class_name.constantize
    end

    def self.pref_labeling_class
      pref_labeling_class_name.constantize
    end

    def self.labeling_class_names
      { pref_labeling_class_name => pref_labeling_languages }.merge(further_labeling_class_names)
    end

    def self.labeling_classes
      { pref_labeling_class => pref_labeling_languages }.merge(further_labeling_classes)
    end

    def self.broader_relation_class
      broader_relation_class_name.constantize
    end

    # returns hash of class name / languages pairs
    # e.g. { "Labeling::SKOS::AltLabel" => ["de", "en"] }
    def self.further_labeling_class_names
      # TODO: custom hash setters to guard against modification of languages arrays?
      return InstanceConfiguration::Defaults.each_with_object({}) do |(key, default_value), hsh|
        prefix = "languages.further_labelings."
        if key.start_with? prefix
          class_name = key[prefix.length..-1]
          hsh[class_name] = InstanceConfiguration.instance[key]
        end
      end
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

    def self.include_modules
      include_module_names.map(&:constantize)
    end

  end

  # ************** Collection specific settings **************

  module Collection

    mattr_accessor :base_class_name

    self.base_class_name = 'Collection::Unordered'

    def self.base_class
      base_class_name.constantize
    end
  end

  # ************** Label specific settings **************

  module Label

    mattr_accessor :base_class_name

    self.base_class_name        = 'Label::SKOS::Base'

    # Do not use the following method in models. This will probably cause a
    # loading loop (something like "expected file xyz to load ...")
    def self.base_class
      base_class_name.constantize
    end

  end

end

# FIXME: For reasons yet unknown, the load hook is executed twice
ActiveSupport.run_load_hooks(:after_iqvoc_config, Iqvoc)
