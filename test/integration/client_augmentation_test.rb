require 'capybara/envjs'

class ClientAugmentationTest < ActionDispatch::IntegrationTest

  setup do
    @concept = Factory.create(:concept, :published_at => nil)
    Factory.create(:concept, :published_at => nil)

    Capybara.current_driver = :envjs
  end

  teardown do
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

    # hover to highlight -- XXX: disabled; unable to trigger hover event
    #concept_row.trigger("mouseover")
    #concept_row.trigger("mouseenter")
    #concept_row.trigger("hover")
    #assert table.has_css?("tr.hover", :count => 1)

    # click row to visit concept page
    concept_row.click
    uri = URI.parse(current_url)
    uri = "%s?%s" % [uri.path, uri.query]
    assert_equal concept_path(@concept, :published => 0, :lang => 'de', :format => 'html'), uri
  end

end
