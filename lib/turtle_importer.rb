class TurtleImporter
  
  def initialize
    @objects = Hash.new
  end
  
  def import(file)
    start_time = Time.now
    
    puts "*** Step 1/3. Creating concepts and labels..."
    step_time = Time.now
    File.foreach(file) do |line|
      unless line.blank?
        triple = extract_triple(line)
        if triple.second == 'rdf:type'
          @objects[triple.first] = case triple.third
          when 'skos:Concept'
            concept = Concept.new(:origin => triple.first)
            concept.save(:validate => false)
            { 'id' => concept.id, 'class' => 'Concept' }
          when 'skosxl:Label'
            label = Label.new(:origin => triple.first)
            label.save(:validate => false)
            { 'id' => label.id, 'class' => 'Label' }
          end
        end
      end
    end
    puts "*** Step 1/3 took #{processing_time(step_time)} minutes so far."
    
    puts "*** Step 2/3. Assigning additional values to concepts and labels..."
    step_time = Time.now
    File.foreach(file) do |line|
      unless line.blank?
        triple = extract_triple(line)
        case triple.second
        when 'skosxl:literalForm'
          Label.find(@objects[triple.first]['id']).from_rdf!(triple.third)
        when 'umt:status'
          Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).update_attribute(:status, triple.third)
        when 'umt:baseForm'
          Label.find(@objects[triple.first]['id']).update_attribute(:base_form, triple.third)
        when 'umt:partOfSpeech'
          Label.find(@objects[triple.first]['id']).update_attribute(:part_of_speech, triple.third)
        when 'umt:inflectionalCode'
          Label.find(@objects[triple.first]['id']).update_attribute(:inflectional_code, triple.third)
        end
      end
    end
    puts "*** Step 2/3 took #{processing_time(step_time)} minutes so far."
    
    puts '*** Step 3/3. Re-casting labels, saving relations and notes...'
    step_time = Time.now
    File.foreach(file) do |line|
      unless line.blank?
        triple = extract_triple(line)
        begin
          final_step(triple)
        rescue Exception => e
          puts "ERROR at <#{triple.first} #{triple.second} #{triple.third}>; #{e.message}"
        end
      end
    end
    puts "*** Step 3/3 took #{processing_time(step_time)} minutes so far."
    
    puts "*** Import finished."
    puts "*** Import process took #{processing_time(start_time)} minutes."
  end
  
  def final_step(triple)
    case triple.second
    ###################
    # SKOSXL attributes
    ###################
    when 'skosxl:prefLabel'
      PrefLabeling.find_or_create_by_owner_id_and_target_id(@objects[triple.first]['id'], @objects[triple.third]['id'])
    when 'skosxl:altLabel'
      AltLabeling.find_or_create_by_owner_id_and_target_id(@objects[triple.first]['id'], @objects[triple.third]['id'])
    when 'skosxl:hiddenLabel'
      HiddenLabeling.find_or_create_by_owner_id_and_target_id(@objects[triple.first]['id'], @objects[triple.third]['id'])
    ###################
    # SKOS attributes
    ###################
    when 'skos:broader'
      Broader.find_or_create_by_owner_id_and_target_id(@objects[triple.first]['id'], @objects[triple.third]['id'])
      # Concept.find(@objects[triple.first]['id']).broader << Concept.find(@objects[triple.third]['id'])
    when 'skos:related'
      Related.find_or_create_by_owner_id_and_target_id(@objects[triple.first]['id'], @objects[triple.third]['id'])
      # Concept.find(@objects[triple.first]['id']).related << Concept.find(@objects[triple.third]['id'])
    when 'skos:narrower'
      Narrower.find_or_create_by_owner_id_and_target_id(@objects[triple.first]['id'], @objects[triple.third]['id'])
      # Concept.find(@objects[triple.first]['id']).narrower << Concept.find(@objects[triple.third]['id'])
    when 'skos:editorialNote'
      Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).editorial_notes.from_rdf!(triple.third)
    when 'skos:definition'
      Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).definitions.from_rdf!(triple.third)
    when 'skos:historyNote'
      Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).history_notes.from_rdf!(triple.third)
    when 'skos:scopeNote'
      Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).scope_notes.from_rdf!(triple.third)
    when 'skos:example'
      Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).examples.from_rdf!(triple.third)
    when 'skos:closeMatch'
      Concept.find(@objects[triple.first]['id']).close_matches.create(:value => triple.third.scan(/:(\d*)/).to_s) if @objects[triple.first]['class'] == "Concept"
    ###################
    # UMT attributes
    ###################
    when 'umt:sourceNote'
      if is_annotation_list?(triple.third)
        Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).umt_source_notes << UMT::SourceNote.new(:owner_type => @objects[triple.first]['class']).from_annotation_list!(triple.third)
      else
        Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).umt_source_notes << UMT::SourceNote.new(:owner_type => @objects[triple.first]['class']).from_rdf(triple.third)
      end
    when 'umt:changeNote'
      if is_annotation_list?(triple.third)
        Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).umt_change_notes << UMT::ChangeNote.new(:owner_type => @objects[triple.first]['class']).from_annotation_list!(triple.third)
      else
        Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).umt_change_notes << UMT::ChangeNote.new(:owner_type => @objects[triple.first]['class']).from_rdf(triple.third)
      end
    when 'umt:usageNote'
      if is_annotation_list?(triple.third)
        Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).umt_usage_notes << UMT::UsageNote.new(:owner_type => @objects[triple.first]['class']).from_annotation_list!(triple.third)
      else
        Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).umt_usage_notes << UMT::UsageNote.new(:owner_type => @objects[triple.first]['class']).from_rdf(triple.third)
      end
    when 'umt:exportNote'
      if is_annotation_list?(triple.third)
        Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).umt_export_notes << UMT::ExportNote.new(:owner_type => @objects[triple.first]['class']).from_annotation_list!(triple.third)
      else
        Kernel.const_get(@objects[triple.first]['class']).find(@objects[triple.first]['id']).umt_export_notes << UMT::ExportNote.new(:owner_type => @objects[triple.first]['class']).from_rdf(triple.third)
      end
    when 'umt:translation'
      UMT::Translation.create(:domain_id => @objects[triple.first]['id'], :range_id => @objects[triple.third]['id'])
      UMT::Translation.create(:domain_id => @objects[triple.third]['id'], :range_id => @objects[triple.first]['id'])
    when 'umt:compoundFrom'
      cf = UMT::CompoundForm.create!(:domain_id => @objects[triple.first]['id'])
      contents = extract_compound_form(triple.third)
      contents.each_with_index do |content, index|
        cf.compound_form_contents.create!(:label_id => @objects[content]['id'], :order => index)
      end
    when 'umt:qualifier'
      UMT::Qualifier.create(:domain_id => @objects[triple.first]['id'], :range_id => @objects[triple.third]['id'])
    when 'umt:homograph'
      UMT::Homograph.create(:domain_id => @objects[triple.first]['id'], :range_id => @objects[triple.third]['id'])
    when 'umt:lexicalExtension'
      UMT::LexicalExtension.create(:domain_id => @objects[triple.first]['id'], :range_id => @objects[triple.third]['id'])
    when 'umt:classified'
      Concept.find(@objects[triple.first]['id']).classifiers << Classifier.find_or_create_by_notation(triple.third)
    end
  end
  
  def default_data_folder
    File.join(RAILS_ROOT, '..', 'umthes_data', 'test.skos')
  end
  
  def extract_compound_form(str)
    str.gsub(/\(|\)|:/, '').split(' ')
  end
  
  def extract_triple(line)
    line.squish!
    triple = line.split(' ', 3)
    triple.each do |e| 
      e.gsub!(/^[:\.]|[:\.]$/, '')
      e.delete!('"') unless e.match(/@[a-zA-Z]{2}|\[.+\]/)
    end
    triple
  end
  
  def is_annotation_list?(str)
    str.match /^\[.*\]$/
  end
  
  def is_compound_form?(str)
    str.match /^\(.+\)$/
  end
  
  def is_literal_form?(str)
    IqvocGlobal::RdfHelper.is_literal_form?(str)
  end
  
  def processing_time(start_time)
    ((Time.now.to_i - start_time.to_i).to_f / 60).round(2)
  end
  
end