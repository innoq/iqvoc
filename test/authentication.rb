require "active_support/concern"

module Authentication
  extend ActiveSupport::Concern

  def login(role = nil)
    logout
    user(role)
    visit new_user_session_path(lang: :de)
    fill_in "E-Mail", with: user.email
    fill_in "Passwort", with: user.password
    click_button "Anmelden"
  end

  def logout
    visit dashboard_path(lang: :de)
    click_link_or_button "Abmelden" if page.has_link?("Abmelden")
    @user.try(:destroy)
    @user = nil
  end

  def user(role = nil)
    @user ||= FactoryGirl.create(:user, role: (role || User.default_role))
  end
end
