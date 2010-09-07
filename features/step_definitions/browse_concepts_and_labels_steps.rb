Given /^I have concepts (.+) labeled (.+)$/ do |concepts, pref_labels|
  concepts    = concepts.split(', ')
  pref_labels = pref_labels.split(', ')
  
  concepts.each_with_index do |concept, index|
    concept = Factory.create(:concept, :origin => concept, :published_at => 2.days.ago)
    label   = Factory.create(:label, :origin => pref_labels[index], :value => pref_labels[index], :published_at => 2.days.ago)
    Factory.create(:pref_labeling, :owner_id => concept.id, :target_id => label.id)
  end
end

Given /^I have a (.+) relation between (.+) and (.+)$/ do |relation, owner, target|
  owner   = Concept.find_by_origin(owner)
  target  = Concept.find_by_origin(target) 
  owner.send(relation.to_sym) << target
end

When /^I follow the link to the format representation (.+)$/ do |format|
  click_link('format_link_ttl')
end

Then /^I should see a Turtle representation for the concept "(.+)"$/ do |origin|
  concept = Concept.find_by_origin(origin)
  visit concept_path(:id => concept, :format => :ttl)
  page.has_content? ":#{concept.origin} rdf:type skos:Concept;"
  page.has_content? "skosxl:prefLabel :Forest;"
end

Then /^I should see a Turtle representation for the label "(.+)"$/ do |origin|
  label = Label.find_by_origin(origin)
  visit label_path(:id => label, :format => :ttl)
  page.has_content? ":#{label.origin} rdf:type skosxl:Label;"
  page.has_content? "skosxl:literalForm #{label.literal_form}."
end