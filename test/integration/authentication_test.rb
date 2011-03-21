require 'test_helper'
require 'integration_test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest

  setup do
  end

  test "sign in" do
    user
    visit dashboard_path(:lang => :de)
    assert page.has_content?("Sie müssen angemeldet sein, um diese Seite aufzurufen")
    visit new_user_session_path(:lang => :de)
    fill_in "E-Mail", :with => user.email
    fill_in "Passwort", :with => user.password
    click_button "Anmelden"
    assert page.has_content?("Anmeldung erfolgreich")
  end

  test "sign out" do
    login
    visit dashboard_path(:lang => :de)
    assert page.has_link?("Abmelden")
    click_link_or_button "Abmelden"
    assert page.has_content?("Abmeldung erfolgreich")
  end

end
