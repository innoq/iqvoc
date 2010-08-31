Given /^there are the following labelings$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |hash|
    concept   = Concept.find_or_create_by_origin_and_published_at(hash[:concept], 2.days.ago)
    label     = Factory.create(:label, :origin => hash[:label], :value => hash[:label].titleize, :published_at => 2.days.ago)
    labeling  = hash[:labeling].constantize.create!(:owner_id => concept.id, :target_id => label.id) 
  end
end

Then /^there should be (\d) results?$/ do |amount|
  assert page.has_css? "dl#search_results dt", :count => 1
end

When /^I choose "([^\"]*)" as query type$/ do |query_type|
  select query_type, :from => "query_type"
end

When /^I indicate to search for "([^\"]*)" with "([^\"]*)" in "([^\"]*)"$/ do |type, query, languages|
  languages = languages.split(', ')
  
  select type, :from => "type"
  fill_in "query", :with => query
  
  languages.each do |language|
    check language
  end
end

When /^I execute the search$/ do
  click_button("Suche")
end

Then /^the results should contain "([^\"]*)"$/ do |term|
  within("dl#search_results dt") do
    page.has_content? term
  end
end