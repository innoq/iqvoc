module Iqvoc
  
  module Concept
    mattr_accessor :base_class_name, 
      :note_class_names,
      :relation_class_names,
      :pref_labeling_class_name, :pref_labeling_languages, :further_labeling_class_names
    
    self.base_class_name          = 'Concept::SKOS::Base'
    self.relation_class_names     = [ 'Concept::Relation::SKOS::Broader::Poly', 'Concept::Relation::SKOS::Narrower', 'Concept::Relation::SKOS::Related' ]
    self.note_class_names         = [ 'Note::SKOS::ChangeNote', 'Note::SKOS::Definition' ]
    self.pref_labeling_class_name = 'Labeling::SKOSXL::PrefLabel'
    self.pref_labeling_languages  = [ :de, :en ]
    self.further_labeling_class_names = { 'Labeling::SKOSXL::AltLabel' => [ :de, :en ] }

    def self.base_class
      base_class_name.constantize
    end
    
    def self.relation_classes
      relation_class_names.map{ |name| name.constantize }
    end

    def self.further_labeling_classes
      further_labeling_class_names.keys.each_with_object({}) do |key, hash|
        hash[key.constantize] = further_labeling_class_names[key]
      end
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
