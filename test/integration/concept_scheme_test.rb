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

require 'integration_test_helper'

class ConceptSchemeTest < ActionDispatch::IntegrationTest

  setup do
    DatabaseCleaner.start
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :_0815 rdf:type skos:Concept
      :_0815 skos:prefLabel "Xen1"@en
      :_0815 skos:prefLabel "Xde1"@de
      :_0815 skos:topConceptOf :scheme
      :_0815 iqvoc:publishedAt "#{2.days.ago}"^^<DateTime>
    EOT
  end

  test 'list top concepts in rdf scheme' do
    visit '/scheme.ttl'

    assert page.has_content? ':scheme a skos:ConceptScheme'
    assert page.has_content? 'skos:hasTopConcept :_0815'
  end

  test 'top terms rdf' do
    visit '/_0815.ttl'

    assert page.has_content? 'skos:topConceptOf :scheme'
  end

end
