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

require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

class EditConceptsTest < ActionDispatch::IntegrationTest

  setup do
    DatabaseCleaner.start
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :foo rdf:type skos:Concept
      :foo skos:prefLabel "Foo"@en
      :foo iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>
    EOT
    @concept = Iqvoc::RDFAPI.cached(:foo)
  end

  test 'create a new concept version' do
    login('administrator')
    visit concept_path(@concept, :lang => 'de', :format => 'html')
    assert page.has_button?('Neue Version erstellen'), "Button 'Neue Version erstellen' is missing on concepts#show"
    click_link_or_button('Neue Version erstellen')
    assert_equal edit_concept_url(@concept, :published => 0, :lang => 'de', :format => 'html'), current_url

    visit concept_path(@concept, :lang => 'de', :format => 'html')
    assert !page.has_button?('Neue Version erstellen'), "Button 'Neue Version erstellen' although there already is a new version"
    assert page.has_link?('Vorschau der Version in Bearbeitung'), "Link 'Vorschau der Version in Bearbeitung' is missing"
    click_link('Vorschau der Version in Bearbeitung')
    assert_equal concept_url(@concept, :published => 0, :lang => 'de', :format => 'html'), current_url
  end

end
