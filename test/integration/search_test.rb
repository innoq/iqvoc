require 'test_helper'
require 'integration_test_helper'

class SearchTest < ActionDispatch::IntegrationTest

  setup do
    @concept1 = Factory(:concept)
    @concept1.pref_label.value = "Tree"
    @concept1.pref_label.save!
    @concept2 = Factory(:concept)
    @concept2.pref_label.value = "Forest"
    @concept2.pref_label.save!
  end

  test "Searching" do
    visit search_path(:lang => 'de', :format => 'html')

    [
      {:type => 'Labels', :query => 'Forest', :query_type => 'enthält', :amount => 1, :result => 'Forest'}
    ].each do |q|
      select q[:type], :from => "t"
      fill_in "q", :with => q[:query]
      select q[:query_type], :from => "qt"

      # select all languages
      page.all(:css, ".lang_check").each do |cb|
        check cb[:id]
      end

      click_button("Suche")

      assert page.has_css?("#search_results dt", :count => q[:amount]), "Page has #{page.all(:css, "#search_results dt").count} '#search_results dt' nodes. Should be #{q[:amount]}."

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
