# encoding: UTF-8

# Copyright 2011-2014 innoQ Deutschland GmbH
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

class ImportTest < ActionDispatch::IntegrationTest

  setup do
    @file = Rails.root.join('data/hobbies.nt')
  end

  test 'import privileges' do
    # guest
    visit imports_path(lang: 'en')
    assert page.has_content? 'No permission'

    ['reader', 'editor', 'publisher'].each do |role|
      login role
      visit imports_path(lang: 'en')
      assert page.has_content?('No permission'), "#{role} must not access exports"
      logout
    end

    login 'administrator'
    visit imports_path(lang: 'en')
    assert page.has_content? 'Import'
  end

  test 'import job creation' do
    login('administrator')
    visit imports_path(lang: 'en')

    attach_file('NTriples file', @file)
    fill_in 'Default namespace', with: 'http://hobbies.com/'
    check('Publish')

    click_button('Import')
    assert page.has_content? 'Import job was created. Reload page to see current processing status.'

    Delayed::Worker.new.work_off
    visit imports_path(lang: 'en')
    page.find('table tbody tr[1] td[1] a').click

    assert page.has_content? 'Output'
    assert page.has_content? 'Publishing of 68 subjects done'
  end

  test 'invalid import form submission' do
    login('administrator')
    visit imports_path(lang: 'en')

    click_button('Import')
    assert page.has_content? 'Error occurred while creating Import job.'

    attach_file('NTriples file', @file)
    fill_in 'Default namespace', with: ''
    click_button('Import')
    assert page.has_content? 'Error occurred while creating Import job.'

    attach_file('NTriples file', nil)
    fill_in 'Default namespace', with: 'http://hobbies.com#'
    click_button('Import')
    assert page.has_content? 'Error occurred while creating Import job.'
  end
end
