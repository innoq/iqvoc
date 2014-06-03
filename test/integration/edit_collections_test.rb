require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

class EditCollectionsTest < ActionDispatch::IntegrationTest

  setup do
    @collection = Collection::SKOS::Unordered.new.publish.tap {|c| c.save }
  end

  test "create a new collection version" do
    login('administrator')
    visit collection_path(@collection, lang: 'de', format: 'html')
    assert page.has_button?("Neue Version erstellen"), "Button 'Neue Version erstellen' is missing on concepts#show"
    click_link_or_button("Neue Version erstellen")
    assert_equal edit_collection_url(@collection, published: 0, lang: 'de', format: 'html'), current_url

    visit collection_path(@collection, lang: 'de', format: 'html')
    assert page.has_no_button?("Neue Version erstellen"), "Button 'Neue Version erstellen' although there already is a new version"
    assert page.has_link?("Vorschau der Version in Bearbeitung"), "Link 'Vorschau der Version in Bearbeitung' is missing"
    click_link("Vorschau der Version in Bearbeitung")
    assert_equal collection_url(@collection, published: 0, lang: 'de', format: 'html'), current_url
  end

end
