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
require 'iqvoc/rdfapi'

class AlphabeticalConceptsTest < ActionDispatch::IntegrationTest

  setup do
    data = [
      { en: 'Xen1', de: 'Xde1' },
      { en: 'Xen2' }
    ]

    data.each_with_index do |hsh, i|
      concept = Iqvoc::RDFAPI.devour "concept_#{i}", 'a', 'skos:Concept'
      labelings = []
      hsh.each do |lang, val|
        Iqvoc::RDFAPI.devour concept, 'skos:prefLabel', "\"#{val}\"@#{lang}"
      end
      concept.publish.save
    end
  end

  test 'showing only concepts with a pref label in respective language' do
    visit alphabetical_concepts_path(lang: :en, prefix: 'x', format: :html)
    concepts = page.all('.concept-items .concept-item')

    assert_equal :en, I18n.locale
    assert_equal 2, concepts.length
    assert_equal 'Xen1', concepts[0].find('.concept-item-link').text.strip
    assert_equal 'Xen2', concepts[1].find('.concept-item-link').text.strip

    visit alphabetical_concepts_path(lang: :de, prefix: 'x', format: :html)
    concepts = page.all('.concept-items .concept-item')

    assert_equal :de, I18n.locale
    assert_equal 1, concepts.length
    assert_equal 'Xde1', concepts[0].find('.concept-item-link').text.strip
  end

end
