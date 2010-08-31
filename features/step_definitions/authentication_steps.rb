def user(role = nil)
  @user ||= Factory.create(:user, :role => (role || User.default_role))
end

def enter_credentials_and_sign_in
  user
  fill_in "E-Mail", :with => user.email
  fill_in "Passwort", :with => user.password
  click_button "Anmelden"
end

def login
  user
  visit new_user_session_path(:lang => :de)
  enter_credentials_and_sign_in
end

def logout
  follow "Abmelden"
end

Given /^I am a logged in user with the role (.+)$/ do |role|
  user(role)
  login
end

Given /^I am a logged out user$/ do 
end

When /^I enter my credentials and sign in$/ do
  enter_credentials_and_sign_in
end