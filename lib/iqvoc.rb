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

module Iqvoc

  mattr_accessor :title,
                 :searchable_class_names,
                 :available_languages,
                 :ability_class_name,
                 :default_rdf_namespace_helper_methods,
                 :change_note_class_name

  self.searchable_class_names = [
    'Labeling::SKOSXL::Base',
    'Labeling::SKOSXL::PrefLabel',
    'Note::Base' ]

  self.available_languages = [:de, :en]

  self.ability_class_name = "::Ability"

  self.default_rdf_namespace_helper_methods = [:iqvoc_default_rdf_namespaces]

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

    self.pref_labeling_class_name     = 'Labeling::SKOSXL::PrefLabel'
    self.pref_labeling_languages      = [ :de ]
    self.further_labeling_class_names = { 'Labeling::SKOSXL::AltLabel' => [ :de, :en ] }

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
      { pref_labeling_class_name => pref_labeling_languages }.merge(further_labeling_class_names)
    end

    def self.labeling_classes
      { pref_labeling_class => pref_labeling_languages }.merge(further_labeling_classes)
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

  module XLLabel # This are the settings when using SKOSXL
    mattr_accessor :base_class_name,
      :note_class_names,
      :relation_class_names,
      :additional_association_class_names,
      :view_sections,
      :has_additional_base_data,
      :searchable_class_names

    self.base_class_name                  = 'Label::SKOSXL::Base'

    self.relation_class_names             = []

    self.note_class_names                 = Iqvoc::Concept.note_class_names

    self.additional_association_class_names = {}

    self.view_sections = ["main", "concepts", "relations", "notes"]

    # Set this to true if you're having a migration which extends the labels table
    # and you want to be able to edit these fields.
    # This is done by:
    #    render :partial => 'partials/label/additional_base_data'
    # You'll have to define this partial
    # FIXME: This wouldn't be necessary if there would be an empty partial in
    # iqvoc and the view loading sequence would be correct.
    self.has_additional_base_data = false

    # Do not use the following method in models. This will propably cause a
    # loading loop (something like "expected file xyz to load ...")
    def self.base_class
      base_class_name.constantize
    end

    def self.relation_classes
      relation_class_names.map(&:constantize)
    end

    def self.note_classes
      note_class_names.map(&:constantize)
    end

    def self.change_note_class
      change_note_class_name.constantize
    end

    def self.additional_association_classes
      additional_association_class_names.keys.each_with_object({}) do |class_name, hash|
        hash[class_name.constantize] = additional_association_class_names[class_name]
      end
    end

  end

  def self.all_classes
    label_classes = []
    if const_defined?(:Label)
      label_classes += [Label.base_class]
    end
    if const_defined?(:XLLabel)
      label_classes += [XLLabel.base_class] + XLLabel.note_classes +
          XLLabel.relation_classes + XLLabel.additional_association_classes.keys
    end
    arr = [Concept.base_class] + Concept.relation_classes +
        Concept.labeling_classes.keys + Concept.match_classes +
        Concept.note_classes + Concept.additional_association_classes.keys +
        label_classes
    arr.uniq
  end

  def self.searchable_classes
    searchable_class_names.map(&:constantize)
  end

end

# FIXME: For yet unknown reasons, the load hook gets to run 2 times
ActiveSupport.run_load_hooks(:after_iqvoc_config, Iqvoc)
