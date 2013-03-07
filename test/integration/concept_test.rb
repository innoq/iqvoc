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

class ConceptTest < ActionDispatch::IntegrationTest

  setup do
    DatabaseCleaner.start
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :foo rdf:type skos:Concept
      :foo skos:prefLabel "Foo"@en
      :foo iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>

      :bar rdf:type skos:Concept
      :bar skos:prefLabel "Bar"@en
      :bar iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>

      :baz rdf:type skos:Concept
      :baz skos:prefLabel "Baz"@en
      :baz iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>
    EOT

    @concept1 = Iqvoc::RDFAPI.cached(:foo)
    @concept2 = Iqvoc::RDFAPI.cached(:bar)
    @concept3 = Iqvoc::RDFAPI.cached(:baz)
  end

  test 'showing published concept' do
    visit '/en/concepts/foo.html'
    assert page.has_content?("#{@concept1.pref_label}")
  end

  test 'persisting inline relations' do
    login 'administrator'

    visit new_concept_path(:lang => 'en', :format => 'html', :published => 0)
    fill_in 'concept_relation_skos_relateds',
        :with => "#{@concept1.origin},#{@concept2.origin},"
    click_button 'Save'

    assert page.has_content? I18n.t('txt.controllers.versioned_concept.success')
    assert page.has_css?('#concept_relation_skos_relateds a', :count => 2)

    click_link_or_button I18n.t('txt.views.versioning.to_edit_mode')
    fill_in 'concept_relation_skos_relateds', :with => ''
    click_button 'Save'

    assert page.has_content? I18n.t('txt.controllers.versioned_concept.update_success')
    assert page.has_no_css?('#concept_relation_skos_relateds a')

    click_link_or_button I18n.t('txt.views.versioning.edit_mode')
    fill_in 'concept_relation_skos_relateds',
        :with => "#{@concept1.origin}, #{@concept2.origin}, #{@concept3.origin}"
    click_button 'Save'

    assert page.has_content? I18n.t('txt.controllers.versioned_concept.update_success')
    assert page.has_css?('#concept_relation_skos_relateds a', :count => 3)
  end

end
