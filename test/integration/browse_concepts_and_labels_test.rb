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

class BrowseConceptsAndLabelsTest < ActionDispatch::IntegrationTest

  setup do
    @concepts = [
      [:en, "Tree"],
      [:en, "Forest"],
      [:de, "Baum"],
      [:de, "Forst"]
    ].map { |lang, text|
      FactoryGirl.create(:concept, :pref_labelings => [FactoryGirl.create(:pref_labeling,
          :target => FactoryGirl.create(:pref_label, :language => lang, :value => text))])
    }
  end

  test "selecting a concept in alphabetical view" do
    letter = "T" # => Only the "Tree" should show up in the english version
    visit alphabetical_concepts_path(:lang => 'en', :prefix => letter, :format => :html)
    assert page.has_link?(@concepts[0].pref_label.to_s),
        "Concept '#{@concepts[0].pref_label}' not found on alphabetical concepts list (prefix: #{letter})"
    assert !page.has_content?(@concepts[1].pref_label.to_s),
        "Found concept '#{@concepts[1].pref_label}' on alphabetical concepts list (prefix: #{letter})"
    click_link_or_button(@concepts[0].pref_label.to_s)
    assert_equal concept_path(@concepts[0], :lang => 'en', :format => :html), URI.parse(current_url).path

    letter = "F" # => Only the "Forest" should show up in the english version
    visit alphabetical_concepts_path(:lang => 'en', :prefix => letter, :format => :html)
    assert page.has_link?("Forest")
    assert !page.has_link?("Forst")
    assert !page.has_link?("Tree")
    assert !page.has_link?("Baum")
  end

  test "showing a concept page" do
    visit concept_url(@concepts[1], :lang => 'en')
    assert page.has_content?("#{@concepts[1].pref_label}"),
        "'Preferred label: #{@concepts[1].pref_label}' missing in concepts#show"
    assert page.has_link?('Turtle'), "RDF link missing in concepts#show"
    click_link_or_button('Turtle')
    assert page.has_content?(":#{@concepts[1].origin} a skos:Concept"),
        "'#{@concepts[1].origin} a skos:Concept' missing in turtle view"
  end

  test "showing concept expired view" do
    #prepare database with expired concept
    concepts = [
        [:en, "Method"],
        [:de, "Methode"]
    ].map { |lang, text|
      FactoryGirl.create(:concept, :expired_at => Time.now - 2.days, :pref_labelings => [FactoryGirl.create(:pref_labeling,
                                                                          :target => FactoryGirl.create(:pref_label, :language => lang, :value => text))])
    }

    visit hierarchical_concepts_path(:lang => 'en')
    click_link_or_button('Expired')
    click_link_or_button('M')
    assert page.has_content?(concepts.first.pref_label.to_s), 'should have one expired concept'
  end

end
