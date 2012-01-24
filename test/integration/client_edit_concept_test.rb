# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

class ClientEditConceptsTest < ActionDispatch::IntegrationTest

  self.use_transactional_fixtures = false

  setup do
    @concept = FactoryGirl.create(:concept)

    Capybara.current_driver = Capybara.javascript_driver
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.use_default_driver
  end

  test "dynamic addition of notes" do
    login("administrator")

    # concept edit view
    visit concept_path(@concept, :lang => "de", :format => "html")
    click_link_or_button("Neue Version erstellen")
    assert page.has_css?("#concept_edit")

    section = page.find("#label_note_skos_definitions_data")
    assert page.has_css?(".note_relation", :count => Iqvoc::Concept.note_class_names.length)
    assert page.has_css?("#label_note_skos_definitions_data", :count => 1)
    assert section.has_css?("li", :count => 1)

    # unhide default note input
    section.find("input[type=button]").click
    assert section.has_css?("li", :count => 1)

    # add another note input
    section.find("input[type=button]").click
    assert section.has_css?("li", :count => 2)

    # add some note text
    section.fill_in "concept_note_skos_definitions_attributes_0_value",
        :with => "lorem ipsum\ndolor sit amet"
    section.fill_in "concept_note_skos_definitions_attributes_1_value",
        :with => "consectetur adipisicing elit"

    assert section.all("textarea")[0].value == "lorem ipsum\ndolor sit amet"
    assert section.all("textarea")[1].value == "consectetur adipisicing elit"

    # save concept
    page.click_link_or_button("Speichern")
    assert page.has_content?("Konzept wurde erfolgreich aktualisiert.")
    # return to edit mode
    page.click_link_or_button("Bearbeitung fortsetzen")
    assert page.has_css?("#concept_edit")

    section = page.find("#label_note_skos_definitions_data")

    assert section.has_css?("li", :count => 2)
    assert section.has_css?("[type=checkbox]", :count => 2)
    assert section.has_no_css?("li.deleted")

    # mark note for deletion
    checkbox_id = "concept_note_skos_definitions_attributes_1__destroy"
    section.check(checkbox_id)
    section.find("##{checkbox_id}").trigger("change") # apparently `check` doesn't do this automatically
    assert section.has_css?("li.deleted", :count => 1)
  end

end
