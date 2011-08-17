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
    @pagination_setting = Kaminari.config.default_per_page
    Kaminari.config.default_per_page = 5


    @concepts =  ["Tree", "Forest"].map do |english_label_value|
      FactoryGirl.create(:concept, :pref_labelings => [
          Factory(:pref_labeling, :target => Factory(:pref_label, :language => :en, :value => english_label_value))
        ])
    end

    # create collection
    @collection = FactoryGirl.create(:collection, :concepts => @concepts,
        :labelings => [], :pref_labelings => [
            Factory(:pref_labeling,
                :target => Factory(:pref_label, :language => :en, :value => "Alpha"))
        ])
  end

  teardown do
    Kaminari.config.default_per_page = @pagination_setting
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

  test "exclude collections from results" do
    visit search_path(:lang => 'en', :format => 'html')

    select "Labels", :from => "t"
    select "contains", :from => "qt"
    fill_in "q", :with => "Alpha"

    click_button("Search")

    assert page.has_no_css?("#search_results dt")
  end

  test "searching within collections" do
    visit search_path(:lang => 'en', :format => 'html')

    select "Labels", :from => "t"
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

    # TTL & RDF/XML 

    ttl_uri = page.all("#abstract_uri a")[-2][:href]
    xml_uri = page.all("#abstract_uri a")[-1][:href]

    visit ttl_uri
    assert page.has_content?("search:result1 a sdc:Result")
    assert page.has_no_content?("search:result2 a sdc:Result")
    assert page.has_content?("sdc:link :#{@concepts[1].origin}")
    assert page.has_content?('skos:prefLabel "Forest"@en')

    visit xml_uri
    assert page.source.include?(@concepts[1].origin)
    assert page.source.include?("<skos:prefLabel xml:lang=\"en\">#{@concepts[1].to_s}</skos:prefLabel>")
  end

  test "searching specific classes within collections" do
    concept = FactoryGirl.create(:concept, { :notes => [
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

    select "Labels", :from => "t"
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

  test "Pagination" do
    # create a large number of concepts
    12.times { |i|
      FactoryGirl.create(:concept,
        :pref_labelings => [Factory(:pref_labeling,
            :target => Factory(:pref_label, :language => :en,
              :value => "sample_#{sprintf("_%04d", i + 1)}"))])
    }

    visit search_path(:lang => 'en', :format => 'html')

    select "Labels", :from => "t"
    select "contains", :from => "qt"
    fill_in "q", :with => "sample_"

    click_button("Search")

    assert page.has_css?("#search_results dt", :count => 5)
    assert page.has_css?(".pagination .page", :count => 3)

    click_link("3")

    assert page.has_css?("#search_results dt", :count => 2)

    # TTL & RDF/XML 

    ttl_uri = page.all("#abstract_uri a")[-2][:href]
    xml_uri = page.all("#abstract_uri a")[-1][:href]

    visit ttl_uri
    assert page.has_content?("sdc:totalResults 12;")
    assert page.has_content?("sdc:itemsPerPage 5;")
    assert page.has_content?("search:result1 a sdc:Result;")
    assert page.has_content?("search:result2 a sdc:Result;")
    assert page.has_no_content?("search:result3 a sdc:Result;") # we're on page 3/3

    visit xml_uri
    assert page.source.include?('<sdc:totalResults rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">12</sdc:totalResults>')
    assert page.source.include?('<sdc:itemsPerPage rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">5</sdc:itemsPerPage>')
    assert page.source.include?('#result1">')
    assert page.source.include?('#result2">')
    assert !page.source.include?('#result3">') # we're on page 3/3
  end

end
