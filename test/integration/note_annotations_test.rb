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

class NoteAnnotationsTest < ActionDispatch::IntegrationTest
  test 'creating and retrieving change notes' do
    login 'administrator'

    visit new_concept_path(lang: 'en', format: 'html', published: 0)
    fill_in 'concept_labelings_by_text_labeling_skos_pref_labels_en',
        with: 'Foo'
    fill_in 'concept_note_skos_change_notes_attributes_0_value',
        with: 'lorem ipsum'
    click_button 'Save'

    assert page.has_content? I18n.t('txt.controllers.versioned_concept.success')

    # has initial created note
    assert page.has_css?('dl.note_annotations', count: 1)

    click_link_or_button I18n.t('txt.views.versioning.publishing')
    assert page.has_content? I18n.t('txt.controllers.versioning.published')

    click_link_or_button I18n.t('txt.views.versioning.versioning_mode')
    fill_in 'concept_note_skos_change_notes_attributes_1_value',
        with: 'dolor sit amet'
    click_button 'Save'

    # initial created note and modified note
    assert page.has_css?('dl.note_annotations', count: 2)

    click_link_or_button I18n.t('txt.views.versioning.publishing')
    assert page.has_content? I18n.t('txt.controllers.versioning.published')
    assert page.has_css?('dl.note_annotations', count: 2)

    # TTL & RDF/XML

    ttl_uri = page.find('#rdf_link_ttl')[:href]
    xml_uri = page.find('#rdf_link_xml')[:href]

    visit ttl_uri
    ttl = page.source.
        gsub(/^ *| *$/, ''). # ignore indentation
        gsub(/\d/, '#').     # neutralize timestamps
        gsub(/#\+#/, '#-#')  # neutralize eventually positive timezone shifts (server time)

    assert ttl.include?("skos:changeNote [\n" +
        "rdfs:comment \"lorem ipsum\"@en;\n" +
        "dct:created \"####-##-##T##:##:##-##:##\";\n" +
        "dct:creator \"Test User\"\n" +
        ']'), "can't find changeNote 'lorem ipsum'"

    assert ttl.include?("skos:changeNote [\n" +
        "rdfs:comment \"dolor sit amet\"@en;\n" +
        "dct:creator \"Test User\";\n" +
        "dct:modified \"####-##-##T##:##:##-##:##\"\n" +
        ']'), "can't find changeNote 'dolor sit amet'"

    visit xml_uri
    xml = page.source.
        gsub(/^ *| *$/, ''). # ignore indentation
        gsub(/\d/, '#').     # neutralize timestamps
        gsub(/#\+#/, '#-#')  # neutralize eventually positive timezone shifts (server time)

    assert xml.include?("<skos:changeNote>\n" +
        "<rdf:Description>\n" +
        "<rdfs:comment xml:lang=\"en\">lorem ipsum</rdfs:comment>\n" +
        "<dct:created>####-##-##T##:##:##-##:##</dct:created>\n" +
        "<dct:creator>Test User</dct:creator>\n" +
        "</rdf:Description>\n" +
        '</skos:changeNote>')
    assert xml.include?("<skos:changeNote>\n" +
        "<rdf:Description>\n" +
        "<rdfs:comment xml:lang=\"en\">dolor sit amet</rdfs:comment>\n" +
        "<dct:creator>Test User</dct:creator>\n" +
        "<dct:modified>####-##-##T##:##:##-##:##</dct:modified>\n" +
        "</rdf:Description>\n" +
        "</skos:changeNote>\n")
  end

  test 'rdf for localized note annotations' do
    rdfapi = RDFAPI

    concept = rdfapi.devour *%w(foobar a skos:Concept)
    concept.publish
    concept.save

    rdfapi.devour concept, 'skos:prefLabel', '"foo"@en'

    note = Note::RDFS::SeeAlso.create owner: concept, value: 'foo', language: 'en'
    note.annotations.create namespace: 'dct', predicate: 'title', value: 'Foo Bar', language: 'en'
    note.annotations.create namespace: 'foaf', predicate: 'page', value: 'http://google.de/'

    visit "/#{concept.origin}.ttl"

    expected_ttl = <<RDF
rdfs:seeAlso [
rdfs:comment "foo"@en;
dct:title "Foo Bar"@en;
foaf:page <http://google.de/>
].
RDF
    ttl = page.source.gsub(/^ *| *$/, '') # ignore indentation
    assert ttl.include?(expected_ttl), "can't find changeNote 'Foo Bar'"
  end
end
