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
    @root_concept = create_concept("foo", "Foo", "en")
  end

  test "root parameter handling" do
    get :index, :format => "html"
    assert_response 400
    assert_equal flash[:error], "missing root parameter"
    entries = css_select("ul.concept-hierarchy li")
    assert_equal entries.length, 0

    get :index, :format => "html", :root => "N/A"
    assert_response 400
    assert_equal flash[:error], "invalid root parameter"
    entries = css_select("ul.concept-hierarchy li")
    assert_equal entries.length, 0

    get :index, :format => "html", :root => @root_concept.origin
    assert_response 200
    assert_equal flash[:error], nil
    entries = css_select("ul.concept-hierarchy li").
        map { |node| node.children.map(&:content).join("") }
    assert_equal entries.length, 1
    assert_equal entries[0], "Foo"
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
