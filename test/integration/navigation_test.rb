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

class NavigationTest < ActionDispatch::IntegrationTest

  test "extensible navigation" do
    Iqvoc::Navigation.add_on_level :root do |n|
      n.item "foo bar", "/"
    end

    Iqvoc::Navigation.add_on_level :group do |n|
      n.item "lulu", "/"
    end

    msg = "Navigation is missing a configured item"

    visit "/"

    assert page.first("#primary").has_link?("foo bar"), msg
    assert page.first("#primary .dropdown-menu").has_link?("lulu"), msg
  end

end
