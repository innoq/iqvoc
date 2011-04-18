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
    @concept1 = Factory(:concept)
    @concept1.pref_label.value = "Tree"
    @concept1.pref_label.save!
    @concept2 = Factory(:concept)
    @concept2.pref_label.value = "Forest"
    @concept2.pref_label.save!
  end

  test "Selecting a concept in alphabetical view" do
    visit alphabetical_concepts_path(:lang => 'de', :letter => @concept1.pref_label.to_s[0, 1], :format => :html)
    assert page.has_link?(@concept1.pref_label.to_s), "Concept '#{@concept1.pref_label}' not found on alphabetical concepts list (letter: #{@concept1.pref_label.to_s[0, 1]})"
    assert !page.has_content?(@concept2.pref_label.to_s), "Found concept '#{@concept2.pref_label}' on alphabetical concepts list (letter: #{@concept1.pref_label.to_s[0, 1]})"
    click_link_or_button(@concept1.pref_label.to_s)
    assert_equal concept_path(@concept1, :lang => 'de', :format => :html), URI.parse(current_url).path
  end

  test "Showing a concept page" do
    visit concept_url(@concept2, :lang => 'de')
    assert page.has_content?("Bevorzugtes Label: #{@concept2.pref_label}"), "'Bevorzugtes Label: #{@concept2.pref_label}' missing in concepts#show"
    assert page.has_link?('Turtle'), "RDF link missing in concepts#show"
    click_link_or_button('Turtle')
    assert page.has_content?(":#{@concept2.origin} a skos:Concept"), "'#{@concept2.origin} a skos:Concept' missing in turtle view"
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
