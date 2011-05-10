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

require 'test_helper'
require 'integration_test_helper'

class BrowseConceptsAndLabelsTest < ActionDispatch::IntegrationTest

  setup do
    # create concepts with labels (avoiding factories due to side-effects)
    @concepts = [
      [:en, "Tree"],
      [:en, "Forest"],
      [:de, "Baum"],
      [:de, "Forst"]
    ].each_with_index.map { |pref_label, i|
      lang, name = pref_label
      concept = Iqvoc::Concept.base_class.create(:origin => "_c00#{i}",
          :published_at => 3.days.ago)
      label = Iqvoc::Concept.pref_labeling_class.label_class.create(
          :origin => "_l00#{i}", :value => name, :language => lang,
          :published_at => 2.days.ago)
      Iqvoc::Concept.pref_labeling_class.create(:owner => concept, :target => label)
      concept
    }
  end

  test "Selecting a concept in alphabetical view" do
    letter = "T"
    visit alphabetical_concepts_path(:lang => 'en', :letter => letter, :format => :html)
    assert page.has_link?(@concepts[0].pref_label.to_s),
        "Concept '#{@concepts[0].pref_label}' not found on alphabetical concepts list (letter: #{letter})"
    assert !page.has_content?(@concepts[1].pref_label.to_s),
        "Found concept '#{@concepts[1].pref_label}' on alphabetical concepts list (letter: #{letter})"
    click_link_or_button(@concepts[0].pref_label.to_s)
    assert_equal concept_path(@concepts[0], :lang => 'en', :format => :html), URI.parse(current_url).path

    letter = "F"
    visit alphabetical_concepts_path(:lang => 'en', :letter => letter, :format => :html)
    assert page.has_link?("Forest")
    assert !page.has_link?("Forst")
    assert !page.has_link?("Tree")
    assert !page.has_link?("Baum")
  end

  test "Showing a concept page" do
    visit concept_url(@concepts[1], :lang => 'en')
    assert page.has_content?("#{@concepts[1].pref_label}"),
        "'Preferred label: #{@concepts[1].pref_label}' missing in concepts#show"
    assert page.has_link?('Turtle'), "RDF link missing in concepts#show"
    click_link_or_button('Turtle')
    assert page.has_content?(":#{@concepts[1].origin} a skos:Concept"),
        "'#{@concepts[1].origin} a skos:Concept' missing in turtle view"
  end

end

=begin
  Scenario: Showing a label page
    Given I am a logged in user with the role reader
    And I have concepts _0000001 labeled Forest
    And I am on the concept page for "_0000001"
    When I follow "Forest"
    Then I should be on the label page for "Forest"
    And I should see "Label: Forest"
    When I follow the link to the format representation for ttl
    Then I should see a Turtle representation for the concept "_0000001"

=end
