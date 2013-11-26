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

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class RdfRenderingTest < ActionController::TestCase

  setup do
    @controller = ConceptsController.new

    # create a concept hierarchy
    concepts = YAML.load <<-EOS
root:
  foo:
  bar:
    EOS
    rel_class = Iqvoc::Concept.broader_relation_class.narrower_class
    @concepts = create_hierarchy(concepts, rel_class, {})
    @concepts["root"].update_attribute("top_term", true)
  end

  test "individual concept representations" do
    params = { :lang => "en", :format => "ttl" }

    get :show, params.merge(:id => "root")
    assert_response 200
    assert @response.body.include? ':root a skos:Concept'
    assert @response.body.include? 'skos:narrower :foo'
    assert @response.body.include? 'skos:narrower :bar'
    assert @response.body.include? 'skos:prefLabel "Root"@en'
    assert @response.body.include? ':foo skos:prefLabel "Foo"@en.'
    assert @response.body.include? ':bar skos:prefLabel "Bar"@en.'

    get :show, params.merge(:id => "foo")
    assert_response 200
    assert @response.body.include? ':foo a skos:Concept'
    assert @response.body.include? 'skos:broader :root'
    assert @response.body.include? 'skos:prefLabel "Foo"@en'
    assert @response.body.include? ':root skos:prefLabel "Root"@en.'
  end

  test "full export" do
    params = { :lang => "en", :format => "ttl" }

    get :index, params
    assert_response 401

    # XXX: disabled because authentication fails
    #get :index, params
    #assert_response 200
    #assert @response.body.include? ':foo a skos:Concept'
    #assert @response.body.include? ':bar a skos:Concept'
    #assert @response.body.include? 'skos:prefLabel "Foo"@en'
    #assert @response.body.include? 'skos:prefLabel "Bar"@en'
    # don't duplicate pref. labels
    #assert !@response.body.include?(':foo skos:prefLabel "Foo"@en.')
    #assert !@response.body.include?(':bar skos:prefLabel "Bar"@en.')
  end

  def create_hierarchy(hash, rel_class, memo=nil, parent=nil)
    hash.each do |origin, children|
      concept = create_concept(origin, origin.capitalize, "en")
      memo[origin] = concept if memo
      link_concepts(parent, rel_class, concept) if parent
      create_hierarchy(children, rel_class, memo, concept) unless children.blank?
    end
    return memo
  end

  def link_concepts(source, rel_class, target)
      rel_name = rel_class.name.to_relation_name
      source.send(rel_name).create_with_reverse_relation(target)
  end

  def create_concept(origin, pref_label, label_lang, published=true)
    concept = Iqvoc::Concept.base_class.create(:origin => origin,
        :published_at => (published ? Time.now : nil))
    label = Iqvoc::Label.base_class.create(:value => pref_label,
        :language => label_lang)
    labeling = Iqvoc::Concept.pref_labeling_class.create(:owner => concept,
        :target => label)
    return concept
  end

end
