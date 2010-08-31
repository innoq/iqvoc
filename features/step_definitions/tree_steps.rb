Given /^I have the concept hierarchy "([^\"]*)"$/ do |names|
  names = names.split(">")
  
  names.each do |name|
    concept = Factory.create(:published_concept)
    label   = Factory.create(:label, :origin => name, :value => name)
    Factory.create(:pref_labeling, :owner_id => concept.id, :target_id => label.id)
  end
  
  concepts = Concept.all
  
  concepts.each_with_index do |concept, index|
    next_concept = concepts[index + 1] unless concept == concepts.last
    if next_concept
      concept.narrower << next_concept
      next_concept.broader << concept
    end
  end
end