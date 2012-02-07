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

  test "Browse hierarchical concepts tree" do
    concept = Factory(:concept, :broader_relations => [])
    narrower_concept = concept.narrower_relations.first.target

    visit hierarchical_concepts_path(:lang => :de, :format => :html)
    assert page.has_link?(concept.pref_label.to_s), 
      "Concept #{concept.pref_label} isn't visible in the hierarchical concepts list"
    assert !page.has_content?(narrower_concept.pref_label.to_s), 
      "Narrower relation (#{narrower_concept.pref_label}) shouldn't be visible in the hierarchical concepts list"
  end

end
