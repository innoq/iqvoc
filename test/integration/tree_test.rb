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

class TreeTest < ActionDispatch::IntegrationTest

  test 'browse hierarchical concepts tree' do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :foo rdf:type skos:Concept
      :foo skos:prefLabel "Foo"@en
      :bar rdf:type skos:Concept
      :bar skos:prefLabel "Bar"@en
      :foo skos:narrower :bar
    EOT

    visit hierarchical_concepts_path(:lang => :de, :format => :html)
    assert page.has_link?('Foo'), 'Concept Foo is not visible in the hierarchical concepts list'
    assert !page.has_content?('Bar'), 'Narrower relation (Bar) should not be visible in the hierarchical concepts list'
  end

end
