require 'integration_test_helper'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

class ClientAugmentationTest < ActionDispatch::IntegrationTest

  self.use_transactional_fixtures = false

  setup do
    @concept = FactoryGirl.create(:concept, :published_at => nil)
    FactoryGirl.create(:concept, :published_at => nil)

    Capybara.current_driver = Capybara.javascript_driver
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.use_default_driver
  end

  test "dashboard concept overview" do
    login("administrator")
    visit dashboard_path(:lang => :de)

    table = page.find("#content table")

    assert table.has_css?("tr", :count => 3)
    assert table.has_css?("tr.highlightable", :count => 2)
    assert table.has_no_css?("tr.hover")

    concept_row = table.all("tr")[1]

    # click row to visit concept page
    concept_row.click
    uri = URI.parse(current_url)
    uri = "%s?%s" % [uri.path, uri.query]
    assert_equal concept_path(@concept, :published => 0, :lang => 'de', :format => 'html'), uri
  end

end
