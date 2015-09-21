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

class ApiDocumentationTest < ActionDispatch::IntegrationTest
  test 'api documentation index' do
    visit apipie_apipie_path
    assert page.has_content?('iQvoc is a Vocabulary Management System for the Semantic Web.')
  end

  test 'api resources documentation' do
    ['Hierarchy', 'Concept scheme', 'Search'].each do |res|
      visit apipie_apipie_path
      click_link res
      assert page.has_content?(res)
    end
  end
end
