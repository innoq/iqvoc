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
require 'iqvoc/skos_importer'

class ExportTest < ActionDispatch::IntegrationTest

  setup do
    @testdata = File.read(Rails.root.join('test','models', 'testdata.nt')).split("\n")
    Iqvoc::SkosImporter.new(@testdata, 'http://www.example.com/').run
  end

  test 'export privileges' do
    # guest
    visit exports_path(:lang => 'en')
    assert page.has_content? 'No permission'

    ['reader', 'editor', 'publisher'].each do |role|
      login role
      visit exports_path(:lang => 'en')
      assert page.has_content?('No permission'), "#{role} must not access exports"
      logout
    end

    login 'administrator'
    visit exports_path(:lang => 'en')
    assert page.has_content? 'Export'
  end

  test 'full export generation' do
    login('administrator')

    visit exports_path(:lang => 'en')
    assert page.has_content? 'Export'

    select('RDF/N-Triples', :from => 'Type')
    fill_in 'Default namespace', :with => 'http://www.example.com/'
    click_link_or_button 'Request Export'
    assert page.has_content? 'Export job was created. Reload page to see current processing status.'

    Delayed::Worker.new.work_off

    visit exports_path(:lang => 'en')
    click_link_or_button 'Download'

    assert_equal 'application/n-triples', page.response_headers['Content-Type']
  end

  test 'invalid export form submission' do
    login('administrator')

    visit exports_path(:lang => 'en')
    assert page.has_content? 'Export'

    select('RDF/N-Triples', :from => 'Type')
    fill_in 'Default namespace', :with => ''
    click_link_or_button 'Request Export'
    assert page.has_content? 'Error occurred while creating Export job.'
  end


end
