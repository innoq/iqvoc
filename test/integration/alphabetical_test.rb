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

class AlphabeticalConceptsTest < ActionDispatch::IntegrationTest

  setup do
    # create concepts with pref labels (avoiding factories due to side-effects)
    @labels = []
    @concepts = [
      ["Xen1", "Xde1"],
      ["Xen2"]
    ].each_with_index.map { |pref_labels, i|
      en_name, de_name = pref_labels
      labels = { :en => en_name }
      if de_name:
        labels[:de] = de_name
      end

      concept = Iqvoc::Concept.base_class.create(:origin => "_c00#{i}",
          :published_at => 3.days.ago)

      j = 0
      labels.each { |lang, name|
        label = Iqvoc::Concept.pref_labeling_class.label_class.create(
            :origin => "_l00#{i}#{j}", :value => name, :language => lang,
            :published_at => 2.days.ago)
        @labels.push(label)
        j += 1
        Iqvoc::Concept.pref_labeling_class.create(:owner => concept, :target => label)
      }

      concept
    }
  end

  test "showing only concepts with a pref label in respective language" do
    visit alphabetical_concepts_path(:lang => :en, :letter => "x", :format => :html)
    lists = page.all("#content ul")
    assert_equal 2, lists.length
    concepts = lists[1].all("li") # XXX: too unspecific

    assert_equal :en, I18n.locale
    assert_equal 2, concepts.length
    assert_equal "Xen1", concepts[0].text.strip
    assert_equal "Xen2", concepts[1].text.strip

    visit alphabetical_concepts_path(:lang => :de, :letter => "x", :format => :html)
    concepts = page.all("#content ul")[1].all("li") # XXX: too unspecific

    assert_equal :de, I18n.locale
    assert_equal 1, concepts.length
    assert_equal "Xde1", concepts[0].text.strip
  end

end
