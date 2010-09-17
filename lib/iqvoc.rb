require 'string'

module Iqvoc
  
  module Concept
    mattr_accessor :base_class_name, 
      :broader_relation_class_name, :further_relation_class_names,
      :pref_labeling_class_name, :pref_labeling_languages, :further_labeling_class_names,
      :note_class_names
    
    self.base_class_name              = 'Concept::SKOS::Base'

    self.broader_relation_class_name  = 'Concept::Relation::SKOS::Broader::Poly'
    self.further_relation_class_names = [ 'Concept::Relation::SKOS::Related' ]

    self.pref_labeling_class_name     = 'Labeling::SKOSXL::PrefLabel'
    self.pref_labeling_languages      = [ :de, :en ]
    self.further_labeling_class_names = { 'Labeling::SKOSXL::AltLabel' => [ :de, :en ] }

    self.note_class_names             = [ 'Note::SKOS::ChangeNote', 'Note::SKOS::Definition' ]

    # Do not use the following method in models. This will propably cause a
    # loading loop (something like "expected file xyz to load ...")
    def self.base_class
      base_class_name.constantize
    end

    def self.pref_labeling_class
      pref_labeling_class_name.constantize
    end

  end
  
  module Label
    mattr_accessor :base_class_name, :note_class_names, :relation_class_names

    self.base_class_name       = 'Label::SKOSXL::Base'
    self.relation_class_names  = []
    self.note_class_names      = [ 'Note::SKOS::Definition',
      'Note::SKOS::HistoryNote',
      'Note::SKOS::ScopeNote',
      'Note::SKOS::EditorialNote',
      'Note::SKOS::Example' ]

    # Do not use the following method in models. This will propably cause a
    # loading loop (something like "expected file xyz to load ...")
    def self.base_class
      base_class_name.constantize
    end

  end
  
end
