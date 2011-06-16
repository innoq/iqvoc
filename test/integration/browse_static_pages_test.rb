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

class BrowseStaticPagesTest < ActionDispatch::IntegrationTest

  test "Show static pages" do
    visit dashboard_url(:lang => 'de', :format => 'html')
    assert page.has_link?("Über"), "Link 'Über' is missing"
    click_link_or_button("Über")
    assert_equal about_url(:lang => 'de', :format => 'html'), current_url
  end

end
