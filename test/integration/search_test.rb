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
  end

  test "Searching" do
    visit search_path(:lang => 'en', :format => 'html')

    [
      {:type => 'Labels', :query => 'Forest', :query_type => 'contains', :amount => 1, :result => 'Forest'}
    ].each do |q|
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

    end

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
