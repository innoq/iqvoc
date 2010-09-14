module Iqvoc
  
  module Concept
    mattr_accessor :base_class_name, :note_class_names, :relation_class_names, :labeling_class_names
    
    self.base_class_name          = 'Concept::SKOS::Base'
    self.relation_class_names     = [ 'Concept::Relation::SKOS::Broader::Poly', 'Concept::Relation::Narrower', 'Concept::Relation::Related' ]
    self.note_class_names         = [ 'Note::SKOS::ChangeNote', 'Note::SKOS::Definition' ]
    self.pref_labeling_class_name = 'Labeling::SKOSXL::PrefLabel'
    self.pref_labeling_languages  = [ :de, :en ]
    self.further_labeling_class_names = { 'Labeling::SKOSXL::AltLabel' => [ :de, :en ] }

    def self.base_class
      base_class_name.constantize
    end
    
    def self.further_labeling_classes
      # TODO
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

    def self.base_class
      base_class_name.constantize
    end

  end
  
end
