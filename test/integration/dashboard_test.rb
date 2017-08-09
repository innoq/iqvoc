# encoding: UTF-8

# Copyright 2011-2017 innoQ Deutschland GmbH
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

class DashboardTest < ActionDispatch::IntegrationTest
  setup do
    @testdata = File.read(Rails.root.join('test','models', 'testdata.nt')).split("\n")
    SkosImporter.new(@testdata, 'http://www.example.com/').run
    Iqvoc::Concept.base_class.update_all(published_at: nil)
    login 'administrator'
  end

  test 'concept dashboard' do
    visit dashboard_path(lang: 'en')
    assert page.body.include? '/en/dashboard.html?sort=value+ASC'
    assert page.body.include? '/en/collection_dashboard.html'
    assert 'http://www.example.com/en/dashboard.html', current_url
    tr_elements = page.find('tbody').all('tr')
    Iqvoc::Concept.base_class.all.each_with_index do |c, i|
      assert_equal c.pref_label.value, tr_elements[i].first('td').text
    end

    find(:xpath, "//a[@href='/en/dashboard.html?sort=value+ASC']").click
    assert 'http://www.example.com/en/dashboard.html?sort=value+ASC', current_url
    assert page.body.include? '/en/dashboard.html?sort=value+ASC'
    assert page.body.include? '/en/dashboard.html?sort=value+ASC%2Cvalue+DESC'

    tr_elements = page.find('tbody').all('tr')
    Iqvoc::Concept.base_class.includes(:pref_labels).order('labels.value ASC').each_with_index do |c, i|
      assert_equal c.pref_label.value, tr_elements[i].first('td').text
    end
  end
end
