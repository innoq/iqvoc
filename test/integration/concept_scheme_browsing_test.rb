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

class ConceptSchemeBrowsingTest < ActionDispatch::IntegrationTest

  test "list top concepts in rdf scheme" do
    @concept = Concept::SKOS::Base.new(top_term: true).publish.tap {|c| c.save }

    visit "/scheme.ttl"

    assert page.has_content? ":scheme a skos:ConceptScheme"
    assert page.has_content? "skos:hasTopConcept :#{@concept.origin}"
  end

  test "top concepts rdf" do
    @concept = Concept::SKOS::Base.new(top_term: true).publish.tap {|c| c.save }

    visit "/#{@concept.origin}.ttl"

    assert page.has_content? "skos:topConceptOf :scheme"
  end

  test "non-top-concept in scheme" do
    non_top_concept = Concept::SKOS::Base.new(top_term: false).publish.tap {|c| c.save }

    visit "/#{non_top_concept.origin}.ttl"

    assert page.has_content?("skos:inScheme :scheme")
    refute page.has_content?("skos:topConceptOf :scheme")
  end

  test "declare top concepts" do
    visit hierarchical_concepts_path(lang: :en, format: :html)

    assert !page.has_link?("Tree 2", href: "http://www.example.com/en/concepts/foo_1.html")
    assert !page.has_link?("Tree 2", href: "http://www.example.com/en/concepts/foo_2.html")

    concept1 = Concept::SKOS::Base.new(origin: "foo_1", top_term: false).publish.tap {|c| c.save }
    Iqvoc::RDFAPI.devour concept1, "skos:prefLabel", '"Tree 2"@en'
    concept2 = Concept::SKOS::Base.new(origin: "foo_2", top_term: false).publish.tap {|c| c.save }
    Iqvoc::RDFAPI.devour concept2, "skos:prefLabel", '"Tree 2"@en'

    login "administrator"
    visit edit_scheme_path(lang: :en, format: :html)

    fill_in "concept_inline_top_concept_origins",
      with: [concept1.origin, concept2.origin].join(",")
    click_button "Save"

    assert page.has_content? "Concept scheme has been saved."

    visit hierarchical_concepts_path(lang: :en, format: :html)

    assert page.has_link? "Tree 2", href: "http://www.example.com/en/concepts/foo_1.html"
    assert page.has_link? "Tree 2", href: "http://www.example.com/en/concepts/foo_2.html"
  end

end
