require 'string'

module Iqvoc

  module Concept
    mattr_accessor :base_class_name, 
      :broader_relation_class_name, :further_relation_class_names,
      :pref_labeling_class_name, :pref_labeling_languages, :further_labeling_class_names,
      :match_class_names,
      :note_class_names,
      :view_sections
    
    self.base_class_name              = 'Concept::SKOS::Base'

    self.broader_relation_class_name  = 'Concept::Relation::SKOS::Broader::Poly'
    self.further_relation_class_names = [ 'Concept::Relation::SKOS::Related' ]

    self.pref_labeling_class_name     = 'Labeling::SKOSXL::PrefLabel'
    self.pref_labeling_languages      = [ :de ]
    self.further_labeling_class_names = { 'Labeling::SKOSXL::AltLabel' => [ :de, :en ] }

    self.note_class_names             = [ 'Note::SKOS::ChangeNote', 
      'Note::SKOS::Definition',
      'Note::SKOS::EditorialNote',
      'Note::SKOS::Example',
      'Note::SKOS::HistoryNote',
      'Note::SKOS::ScopeNote',
      'Note::UMT::ChangeNote',
      'Note::UMT::ExportNote',
      'Note::UMT::SourceNote',
      'Note::UMT::UsageNote' ]

    self.match_class_names            = [ 'Match::SKOS::Close', 
      'Match::SKOS::Broader',
      'Match::SKOS::Narrower',
      'Match::SKOS::Related',
      'Match::SKOS::Exact' ]

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

    def self.relation_classes
      further_relation_classes + [broader_relation_class, broader_relation_class.narrower_class]
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

  end
  
  module XLLabel
    mattr_accessor :base_class_name, 
      :note_class_names,
      :relation_class_names,
      :label_relation_class_names,
      :compound_form_class_name,
      :compound_form_content_class_name,
      :view_sections

    self.base_class_name                  = 'Label::UMT::Base'

    self.relation_class_names             = [
      'Label::Relation::UMT::Translation',
      'Label::Relation::UMT::Homograph',
      'Label::Relation::UMT::Qualifier',
      'Label::Relation::UMT::LexicalExtension' ]

    self.note_class_names                 = Iqvoc::Concept.note_class_names

    self.compound_form_class_name         = 'CompoundForm::UMT::Base'
    self.compound_form_content_class_name = 'CompoundForm::Content::UMT::Base'

    self.view_sections = ["main", "concepts", "inflectionals", "relations", "notes", "compound_forms"]

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

  end
  
end
