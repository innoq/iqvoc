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

class UserManagementTest < ActionDispatch::IntegrationTest

  setup do
  end

  test "create user" do
    login "administrator"

    visit users_path(:lang => :en)
    assert page.has_content?("Test User")
    assert page.has_css?('.users-table-row', :count => 1)
    click_link "New User"

    fill_in "Forename", :with => "Arnulf"
    fill_in "Surname", :with => "Beckenbauer"
    fill_in "Email", :with => "arnulf@beckenbauer.com"
    fill_in "Password", :with => "secret"
    fill_in "Password (Confirmation)", :with => "secret"
    click_button "Save"

    assert page.has_content?("Arnulf Beckenbauer")
    assert page.has_css?('.users-table-row', :count => 2)
  end

  test "delete user" do
    login "administrator"
    visit users_path(:lang => :en)
    assert page.has_css?('.users-table-row', :count => 1)
    within ".users-table-row" do
      click_on "Delete"
    end
    assert page.has_css?('.users-table-row', :count => 0)
  end
end
