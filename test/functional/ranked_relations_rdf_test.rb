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

require 'iqvoc/maker'

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class RankedRelationsRdfTest < ActionController::TestCase

  setup do
    @controller = RdfController.new

    Iqvoc::Maker.from_yaml <<-EOF
      labels:
      -
        value: Foo
        language: en
      -
        value: Bar
        language: en

      concepts:
      -
        pref_labels: [Foo]
        top_term: true
      -
        pref_labels: [Bar]
        broader: Foo
    EOF
    @top_term = Iqvoc::Concept.base_class.first
    @concept = Iqvoc::Concept.base_class.last

    @top_term.concept_relation_skos_relateds.
        create_with_reverse_relation(@concept, :rank => 13)
  end

  test "Turtle representation of individual concepts" do
    get :show, :id => @top_term.origin, :format => "ttl"

    assert_response :success
    assert @response.body.include?(":#{@top_term.origin} a skos:Concept;")
    assert @response.body.include?('skos:prefLabel "Foo"@en;')
    assert @response.body.include?("skos:narrower :#{@concept.origin};")
    compact_body = @response.body.gsub(/  */, " ")
    assert compact_body.include?("schema:rankedRelated [" +
        "\n schema:relationWeight 13;" +
        "\n schema:relationTarget :#{@concept.origin}" +
        "\n].")

    get :show, :id => @concept.origin, :format => "ttl"

    assert_response :success
    assert @response.body.include?('skos:prefLabel "Bar"@en;')
    assert @response.body.include?("skos:broader :#{@top_term.origin};")
    compact_body = @response.body.gsub(/  */, " ")
    assert compact_body.include?("schema:rankedRelated [" +
        "\n schema:relationWeight 13;" +
        "\n schema:relationTarget :#{@top_term.origin}" +
        "\n].")

  end

end
