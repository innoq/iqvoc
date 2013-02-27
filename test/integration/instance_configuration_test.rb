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
    uri = "/en/config"

    # guest
    visit uri
    assert page.has_content?("No permission")

    ["reader", "editor", "publisher"].each do |role|
      login role
      visit uri
      assert page.has_content?("No permission"), "#{role} must not access instance configuration"
      logout
    end

    login "administrator"
    visit uri
    assert_equal "/en/config.html", page.current_path
    assert page.has_css?("input#config_title")
    assert page.has_css?("input#config_available_languages")
    assert page.has_selector?(:xpath, '//input[@id="config_languages.pref_labeling"]')
    assert page.has_selector?(:xpath, '//input[@id="config_languages.further_labelings.Labeling::SKOS::AltLabel"]')

    # TODO: also test POST
  end

  test "modify and persist configuration" do
    assert page.find("a.brand").has_content? "iQvoc"

    login "administrator"
    visit "/en/config"

    fill_in "config_title", :with => "lorem ipsum"
    click_button "Save"

    assert page.find("a.brand").has_content? "lorem ipsum"

    # ensure that settings persist across sessions -- XXX: ineffective!?
    check_page = lambda { |uri|
      visit uri
      assert page.find("a.brand").has_content? "lorem ipsum"
    }
    ["reader", "editor", "publisher", "administrator"].each do |role|
      login role
      check_page.call "/en/config"
      logout
      check_page.call "/en/search"
    end

    # TODO: test routes-by-language availability, post-modification
  end

end
