# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

class AuthenticationTest < ActionDispatch::IntegrationTest
  test 'sign in' do
    user
    visit dashboard_path(lang: :de)
    assert page.has_content?('Keine Berechtigung')
    visit new_user_session_path(lang: :de)
    fill_in 'E-Mail', with: user.email
    fill_in 'Passwort', with: user.password
    click_button 'Anmelden'
    assert page.has_content?('Anmeldung erfolgreich')
  end

  test 'sign out' do
    login
    visit dashboard_path(lang: :de)
    assert page.has_link?('Abmelden')
    click_link_or_button 'Abmelden'
    assert page.has_content?('Abmeldung erfolgreich')
  end
end
