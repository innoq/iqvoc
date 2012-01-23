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

require 'test_helper'
require 'integration_test_helper'

class InstanceConfigurationTest < ActionDispatch::IntegrationTest

  test "configuration privileges" do
    uri = "/config"

    # guest
    visit uri
    assert_equal "/en/user_session/new.html", page.current_path

    for role in ["reader", "editor", "publisher"]
      login role
      visit uri
      assert_equal "/en/user_session/new.html", page.current_path,
          "#{role} must not access instance configuration"
      logout
    end

    login "administrator"
    visit uri
    assert_equal "/en/config.html", page.current_path
    assert page.has_css?("fieldset input", :count => 4)
    assert page.has_css?("input#config_title")
    assert page.has_css?("input#config_available_languages")
    assert page.has_selector?(:xpath, '//input[@id="config_languages.pref_labeling"]')
    assert page.has_selector?(:xpath, '//input[@id="config_languages.further_labelings.Labeling::SKOS::AltLabel"]')

    # TODO: also test POST
  end

  test "modify and persist configuration" do
    assert page.find("h1.header").has_content? "iQvoc"

    login "administrator"
    visit "/config"

    fill_in "config_title", :with => "lorem ipsum"
    click_button "Save"

    assert page.find("h1.header").has_content? "lorem ipsum"

    # ensure that settings persist across sessions -- XXX: ineffective!?
    check_page = lambda { |uri|
      visit uri
      assert page.find("h1.header").has_content? "lorem ipsum"
    }
    for role in ["reader", "editor", "publisher", "administrator"]
      login role
      check_page.call "/config"
      logout
      check_page.call "/search"
    end

    # TODO: test routes-by-language availability, post-modification
  end

end
