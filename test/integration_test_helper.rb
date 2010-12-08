require 'test_helper'
require 'capybara/rails'

module ActionController
  class IntegrationTest
    include Capybara

    def login(role = nil)
      logout
      user(role)
      visit new_user_session_path(:lang => :de)
      fill_in "E-Mail", :with => user.email
      fill_in "Passwort", :with => user.password
      click_button "Anmelden"
    end

    def logout
      visit dashboard_path(:lang => :de)
      click_link_or_button "Abmelden" if page.has_link?("Abmelden")
    end

    def user(role = nil)
      @user ||= Factory.create(:user, :role => (role || User.default_role))
    end

  end
end
