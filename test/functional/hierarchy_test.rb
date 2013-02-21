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

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class HierarchyTest < ActionController::TestCase

  setup do
    @controller = HierarchyController.new

    # create a concept hierarchy

    concepts = YAML.load <<-EOS
root:
  foo:
  bar:
    alpha:
    bravo:
      uno:
      dos:
        lorem:
        ipsum:
    EOS
    rel_class = Iqvoc::Concept.broader_relation_class.narrower_class
    @concepts = create_hierarchy(concepts, rel_class, {})
  end

  test "root parameter handling" do
    assert_raises(ActionController::RoutingError) do
      get :show, :format => "html"
    end

    get :show, :format => "html", :root => "N/A"
    assert_response 400
    assert_equal flash[:error], "invalid root parameter"
    entries = css_select("ul.concept-hierarchy li")
    assert_equal entries.length, 0

    get :show, :format => "html", :root => "root"
    assert_response 200
    assert_equal flash[:error], nil
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries.length, 1
    assert_equal entries[0], "Root"

    get :show, :format => "html", :root => "root"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = get_entries("ul.concept-hierarchy li li")
    assert_equal entries, ["Foo", "Bar"]
    entries = get_entries("ul.concept-hierarchy li li li")
    assert_equal entries, ["Alpha", "Bravo"]
    entries = get_entries("ul.concept-hierarchy li li li li")
    assert_equal entries, ["Uno", "Dos"]
    entries = css_select("ul.concept-hierarchy li li li li li")
    assert_equal entries.length, 0 # exceeded default depth

    get :show, :format => "html", :root => "bravo"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Bravo"]
    entries = get_entries("ul.concept-hierarchy li li")
    assert_equal entries, ["Uno", "Dos"]
    entries = get_entries("ul.concept-hierarchy li li li")
    assert_equal entries, ["Lorem", "Ipsum"]
    entries = css_select("ul.concept-hierarchy li li li li")
    assert_equal entries.length, 0

    get :show, :format => "html", :root => "lorem"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Lorem"]
    entries = css_select("ul.concept-hierarchy li li")
    assert_equal entries.length, 0
  end

  test "depth handling" do
    selector = "ul.concept-hierarchy li li li li li"

    get :show, :format => "html", :root => "root"
    entries = css_select(selector)
    assert_equal entries.length, 0 # default depth is 3

    get :show, :format => "html", :root => "root", :depth => 4
    entries = css_select(selector)
    assert_equal entries.length, 2

    get :show, :format => "html", :root => "root", :depth => 1
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = get_entries("ul.concept-hierarchy li li")
    assert_equal entries, ["Foo", "Bar"]
    entries = css_select("ul.concept-hierarchy li li li")
    assert_equal entries.length, 0

    get :show, :format => "html", :root => "root", :depth => "invalid"
    assert_response 400
    assert_equal flash[:error], "invalid depth parameter"
  end

  test "direction handling" do
    get :show, :format => "html", :root => "root"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = get_entries("ul.concept-hierarchy li li li li")
    assert_equal entries, ["Uno", "Dos"]

    get :show, :format => "html", :root => "root", :dir => "up"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Root"]
    entries = css_select("ul.concept-hierarchy li li")
    assert_equal entries.length, 0

    get :show, :format => "html", :root => "lorem"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Lorem"]
    entries = css_select("ul.concept-hierarchy li li")
    assert_equal entries.length, 0

    get :show, :format => "html", :root => "lorem", :dir => "up"
    entries = get_entries("ul.concept-hierarchy li")
    assert_equal entries, ["Lorem"]
    entries = get_entries("ul.concept-hierarchy li li li li")
    assert_equal entries, ["Bar"]
    entries = css_select("ul.concept-hierarchy li li li li li")
    assert_equal entries.length, 0

    get :show, :format => "html", :root => "lorem", :dir => "up", :depth => 4
    entries = get_entries("ul.concept-hierarchy li li li li li")
    assert_equal entries, ["Root"]
  end

  def get_entries(selector)
    return css_select(selector).map { |node| node.children.first.content }
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
