require 'test_helper'
require 'integration_test_helper'

class BrowseStaticPagesTest < ActionDispatch::IntegrationTest

  setup do
  end

  test "Show static pages" do
    visit dashboard_url(:lang => 'de', :format => 'html')
    assert page.has_link?("Über"), "Link 'Über' is missing"
    click_link_or_button("Über")
    assert_equal about_path(:lang => 'de', :format => 'html'), current_path
  end

end
