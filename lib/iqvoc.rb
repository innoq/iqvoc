require 'string'

module Iqvoc
  
  mattr_accessor :searchable_class_names
  
  self.searchable_class_names = [
       'Labeling::SKOSXL::Base',
       'Labeling::SKOSXL::PrefLabel',
       'Note::Base' ]

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
      'Note::SKOS::ScopeNote' ]

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
    
    def self.supports_multi_language_pref_labelings?
      pref_labeling_languages.size > 1
    end

  end

  module Label # This are the settings when using SKOS
    mattr_accessor :base_class_name

    self.base_class_name = 'Label::SKOS::Base'

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

    self.view_sections = ["main", "concepts", "inflectionals", "relations", "notes"]
    
    # Set this to true if you're having a migration which extends the labels table
    # and you want to be able to edit these fields.
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
      label_classes += [XLLabel.base_class] + XLLabel.note_classes + XLLabel.relation_classes + XLLabel.additional_association_classes.keys
    end   
    arr = [Concept.base_class] + Concept.relation_classes + Concept.labeling_classes.keys + Concept.match_classes + Concept.note_classes + label_classes
    arr.uniq
  end
  
  def self.searchable_classes
    searchable_class_names.map(&:constantize)
  end

end
