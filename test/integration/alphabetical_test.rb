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

class AlphabeticalConceptsTest < ActionDispatch::IntegrationTest

  setup do
     Iqvoc::RDFAPI.parse_triples <<-EOT
      :c1 rdf:type skos:Concept
      :c1 skos:prefLabel "Xen1"@en
      :c1 skos:prefLabel "Xde1"@de

      :c2 rdf:type skos:Concept
      :c2 skos:prefLabel "Xen2"@en
    EOT
  end

  test 'should only show concepts with a pref label in respective language' do
    visit alphabetical_concepts_path(:lang => :en, :prefix => 'x', :format => :html)
    concepts = page.all('ol.concepts li')

    assert_equal :en, I18n.locale
    assert_equal 2, concepts.length
    assert_equal 'Xen1', concepts[0].find('p.term').text.strip
    assert_equal 'Xen2', concepts[1].find('p.term').text.strip

    visit alphabetical_concepts_path(:lang => :de, :prefix => 'x', :format => :html)
    concepts = page.all('ol.concepts li')

    assert_equal :de, I18n.locale
    assert_equal 1, concepts.length
    assert_equal 'Xde1', concepts[0].find('p.term').text.strip
  end

end
