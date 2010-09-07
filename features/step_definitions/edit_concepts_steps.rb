Then /^I should see a button to create a new version$/ do
  assert page.has_css?("div.editing_versioning_toolbar form.button_to input[type=submit]")
end

Then /^I should not see a button to create a new version$/ do
  assert !page.has_css?("div.editing_versioning_toolbar form.button_to input[type=submit]")
end