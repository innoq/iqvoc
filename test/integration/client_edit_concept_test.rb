require 'test_helper'
require 'integration_test_helper'
require 'capybara/envjs'
#require 'database_cleaner'

#DatabaseCleaner.strategy = :truncation

class ClientEditConceptsTest < ActionDispatch::IntegrationTest

  #self.use_transactional_fixtures = false

  setup do
    @concept = Iqvoc::Concept.base_class.create(:origin => "_666",
        :published_at => Time.now)

    # create a user
    password = "FooBar"
    @admin = User.create(:forename => "John", :surname => "Doe",
        :email => "foo@example.org",
        :password => password, :password_confirmation => password,
        :active => true, :role => "administrator")
    @admin.password = password # required because password is only saved in encrypted form

    Capybara.current_driver = :envjs
    #DatabaseCleaner.start
  end

  teardown do
    #DatabaseCleaner.clean
    Capybara.use_default_driver
  end

  test "dynamic addition of notes" do
    # login
    visit new_user_session_path(:lang => :de)
    fill_in "E-Mail", :with => @admin.email
    fill_in "Passwort", :with => @admin.password
    click_button "Anmelden"
    assert page.has_no_css?(".flash_error")
    assert page.has_content?("Anmeldung erfolgreich")
    # concept edit view
    visit concept_path(@concept, :lang => "de", :format => "html")
    click_link_or_button("Neue Version erstellen")

    section = page.find("#label_note_skos_definitions_data")
    assert page.has_css?(".note_relation", :count => Iqvoc::Concept.note_class_names.length)
    assert page.has_css?("#label_note_skos_definitions_data", :count => 1)
    assert section.has_css?("li", :count => 1)

    # unhide default note input
    section.click_link_or_button("Weitere hinzufügen")

    assert section.has_css?("li", :count => 1)

    # add another note input
    before = page.find("body").text
    section.click_link_or_button("Weitere hinzufügen")
    after = page.find("body").text

    assert before != after
    assert section.has_css?("li", :count => 2)
  end

end
