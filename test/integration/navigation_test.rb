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
  test 'extend navigation on root level' do
    Navigation.add({
      text: 'root element 1',
      href: 'http://foo.local/'
    })

    Navigation.add_grouped({
      text: 'extension 1',
      href: 'http://foo.local/'
    })

    visit '/en'

    nav = page.first('.navbar-fixed-top')

    assert nav.has_link?('root element 1'),
      'Configured navbar element is missing or not in expected position'
    assert nav.has_link?('Extensions'),
      'Configured navbar element is missing or not in expected position'

    dropdown = nav.all('.dropdown-menu')[1]

    assert_equal 1, dropdown.all('li').size
    assert dropdown.first('li').has_link?('extension 1')
  end
end
