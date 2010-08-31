namespace :umthes do
  
  desc "Move concept definitions to the according prefLabel."
  task :move_definitions => :environment do
    moved, destroyed = 0, 0
    
    puts "Found #{Definition.for_concepts.count} concept definitions."
    puts "Found #{Definition.for_labels.count} label definitions."
    
    Definition.for_concepts.each do |concept_definition|
      pref_label = concept_definition.owner.pref_label
      if Definition.for_labels.find_by_language_and_value_and_owner_id_and_owner_type(concept_definition.language, 
          concept_definition.value, pref_label.id, 'Label')
        # Concept Definition löschen, wenn schon eine identische Definition für das zugehörige PrefLabel vorhanden ist
        concept_definition.destroy
        destroyed += 1
      else
        # Anderenfalls: Definition dem PrefLabel zuordnen
        concept_definition.update_attributes(:owner_id => pref_label.id, :owner_type => 'Label')
        moved += 1
      end
    end
    
    puts "Moved #{moved} concept definitions to the according PrefLabels."
    puts "Destroyed #{destroyed} concept definitions because of redundancy."
    puts "Found #{Definition.for_labels.count} label definitions."
  end
  
  desc "Publishes all concepts and labels."
  task :publish_all => :environment do
    time = Time.now
    [Concept, Label].each { |c| c.update_all(["published_at = ?", time]) }
  end
  
  desc "Generate inflectionals based on a mapping table in the Inflectional model class."
  task :generate_inflectionals => :environment do
    Label.find_each do |label|
      label.generate_inflectionals!
    end
  end
  
  task :import_translations => :environment do
    file = File.expand_path("../umthes_data/expths.csv")
    
    File.foreach(file) do |line|
      values = line.split(",")
      if values.second.blank?
        next
      end
      
      # unless na1 = NoteAnnotation.find_by_identifier_and_value("umt:thsisn", "\"#{sprintf("%08d", values.first.to_i)}\"")
      unless na1 = NoteAnnotation.first(:conditions => ["note_annotations.identifier = ? AND note_annotations.value = ? AND notes.owner_type = ?", "umt:thsisn", "\"#{sprintf("%08d", values.first.to_i)}\"", "Label"], :joins => :note)
        puts line
        puts "Error: Can't find NoteAnnotation umt:thsisn \"#{sprintf("%08d", values.first.to_i)}\""
      end
      
      # unless na2 = NoteAnnotation.find_by_identifier_and_value("umt:thsisn", "\"#{sprintf("%08d", values.second.to_i)}\"")
      unless na2 = NoteAnnotation.first(:conditions => ["note_annotations.identifier = ? AND note_annotations.value = ? AND notes.owner_type = ?", "umt:thsisn", "\"#{sprintf("%08d", values.second.to_i)}\"", "Label"], :joins => :note)
        puts line
        puts "Error: Can't find NoteAnnotation umt:thsisn \"#{sprintf("%08d", values.second.to_i)}\""
      end
      
      next unless na1.present?
      next unless na2.present?
      
      UMT::Translation.create!(:domain_id => na1.note.owner.id, :range_id => na2.note.owner.id)
      UMT::Translation.create!(:domain_id => na2.note.owner.id, :range_id => na1.note.owner.id)
    end
  end
  
  
  
end