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

class SearchTest < ActionDispatch::IntegrationTest

  setup do
    # create concepts with labels (avoiding factories due to side-effects)
    @concepts = [
      [:en, "Tree"],
      [:en, "Forest"]
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
    # create collection
    @collection = Factory.create(:collection, { :concepts => @concepts })
  end

  test "Searching" do
    visit search_path(:lang => 'en', :format => 'html')

    [{
      :type => 'Labels', :query => 'Forest', :query_type => 'contains',
      :amount => 1, :result => 'Forest'
    }].each { |q|
      select q[:type], :from => "t"
      fill_in "q", :with => q[:query]
      select q[:query_type], :from => "qt"

      # select all languages
      page.all(:css, ".lang_check").each do |cb|
        check cb[:id]
      end

      click_button("Search")

      assert page.has_css?("#search_results dt", :count => q[:amount]),
          "Page has #{page.all(:css, "#search_results dt").count} '#search_results dt' nodes. Should be #{q[:amount]}."

      within("#search_results dt") do
        assert page.has_content?(q[:result]), "Could not find '#{q[:result]}' within '#search_results dt'."
      end
    }
  end

  test "searching within collections" do
    visit search_path(:lang => 'en', :format => 'html')

    select "All names", :from => "t"
    select "contains", :from => "qt"
    fill_in "q", :with => "res"
    select @collection.to_s, :from => "c"

    # select all languages
    page.all(:css, ".lang_check").each do |cb|
      check cb[:id]
    end

    click_button("Search")

    assert page.has_css?("#search_results dt", :count => 1)
    assert page.find("#search_results").has_content?("Forest")

    # TTL & RDF/XML -- XXX: should be a separate test

    ttl_uri = page.all("#abstract_uri a").first[:href]
    xml_uri = page.all("#abstract_uri a").last[:href]

    visit ttl_uri
    assert page.has_content?("search:result1 a sdc:Result")
    assert page.has_no_content?("search:result2 a sdc:Result")
    assert page.has_content?("sdc:link :#{@concepts[1].origin}")
    assert page.has_content?('skos:prefLabel "Forest"@en')

    visit xml_uri
    assert page.has_content?(@concepts[1].origin)
    assert page.has_content?("<skos:prefLabel xml:lang=\"en\">#{@concepts[1].to_s}</skos:prefLabel>")
  end

  test "searching specific classes within collections" do
    concept = Factory.create(:concept, { :notes => [
        Iqvoc::Concept.note_classes[1].new(:language => "en", :value => "lorem ipsum")
    ] })

    visit search_path(:lang => 'en', :format => 'html')

    select "Notes", :from => "t"
    select "contains", :from => "qt"
    fill_in "q", :with => "ipsum"
    select @collection.to_s, :from => "c"

    # select all languages
    page.all(:css, ".lang_check").each do |cb|
      check cb[:id]
    end

    click_button("Search")

    assert page.has_css?("#search_results dt", :count => 1)
    assert page.find("#search_results").has_content?(concept.origin)
  end

  test "empty query with selected collection should return all collection members" do
    visit search_path(:lang => 'en', :format => 'html')

    select "All names", :from => "t"
    select "exact match", :from => "qt"
    fill_in "q", :with => ""
    select @collection.to_s, :from => "c"

    # select all languages
    page.all(:css, ".lang_check").each do |cb|
      check cb[:id]
    end

    click_button("Search")

    assert page.has_css?("#search_results dt", :count => 2)
    assert page.find("#search_results").has_content?("Tree")
    assert page.find("#search_results").has_content?("Forest")
  end

end

=begin

      | concept  | label           | labeling      |
      | _0000001 | Forest          | PrefLabeling  |
      | _0000002 | Tree            | PrefLabeling  |
      | _0000002 | ThingWithLeaves | AltLabeling   |


    When I indicate to search for "<type>" with "<query>" in "<languages>"
    And I choose "<query_type>" as query type
    And I execute the search
    Then there should be <amount> result
    And the results should contain "<result>"

    Examples:
      | type                      | query             | languages         | query_type | amount | result               |
      | bevorzugte Namen (Labels) | Forest            | Deutsch, English  | enthält    | 1      | Forest               |
      | alle Namen (Labels)       | thing with leaves | Deutsch, English  | enthält    | 1      | Thing With Leaves    |

=end
