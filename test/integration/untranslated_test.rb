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

class UntranslatedConceptsTest < ActionDispatch::IntegrationTest

  setup do
    DatabaseCleaner.start

    Iqvoc::RDFAPI.parse_triples <<-EOT
      :c1 rdf:type skos:Concept
      :c1 skos:prefLabel "Xen1"@en
      :c1 skos:prefLabel "Xde1"@de

      :c2 rdf:type skos:Concept
      :c2 skos:prefLabel "Xen2"@en

      :c3 rdf:type skos:Concept
      :c3 skos:prefLabel "Yen1"@en
      :c3 skos:prefLabel "Yde1"@de

      :c4 rdf:type skos:Concept
      :c4 skos:prefLabel "Yen2"@en
    EOT
  end

  # FIXME: apparently these tests are bogus, as they passed even when they
  # should fail (see the commit that introduced this very comment for details)

  test 'should only show concepts without pref label in respective language' do
    visit untranslated_concepts_path(:lang => :de, :prefix => 'x', :format => :html)
    concepts = page.all('#content ul')[1].all('li') # XXX: too unspecific

    assert_equal :de, I18n.locale
    assert_equal 1, concepts.length
    assert_equal 1, concepts[0].all('a').length
    assert_equal 'Xen2', concepts[0].find('a').text.strip

    visit untranslated_concepts_path(:lang => :de, :prefix => 'y', :format => :html)
    concepts = page.all('#content ul')[1].all('li') # XXX: too unspecific

    assert_equal 1, concepts.length
    assert_equal 'Yen2', concepts[0].find('a').text.strip
  end

  test 'showing error message for main thesaurus  language' do
    visit untranslated_concepts_path(:lang => :en, :prefix => 'x', :format => :html)

    assert_equal :en, I18n.locale
    assert_equal 1, page.all('#content .alert-error').length
  end

end
