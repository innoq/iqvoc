# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
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

require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper')
require 'capybara/rails'

module ActionController
  class IntegrationTest
    include Capybara::DSL

    Capybara.javascript_driver = :webkit

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
      @user.try(:destroy)
      @user = nil
    end

    def user(role = nil)
      @user ||= FactoryGirl.create(:user, :role => (role || User.default_role))
    end

  end
end
