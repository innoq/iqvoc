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

require 'test_helper'
require 'integration_test_helper'

class UntranslatedConceptsTest < ActionDispatch::IntegrationTest

  setup do
    # create concepts with pref labels (avoiding factories due to side-effects)
    @labels = []
    @concepts = [
      ["Xen1", "Xde1"],
      ["Xen2"],
      ["Yen1", "Yde1"],
      ["Yen2"]
    ].each_with_index.map { |pref_labels, i|
      en_name, de_name = pref_labels
      labels = { :en => en_name }
      if de_name
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

    # reuse exiting label as alt label
    Iqvoc::Concept.further_labeling_classes.first.first. # XXX: .first.first hacky!?
        create(:owner => @concepts.first, :target => @labels.last)
  end

  test "showing only concepts without pref label in respective language" do
    visit untranslated_concepts_path(:lang => :de, :letter => "x", :format => :html)
    concepts = page.all("#content ul")[1].all("li") # XXX: too unspecific

    assert_equal :de, I18n.locale
    assert_equal 1, concepts.length
    assert_equal 1, concepts[0].all("a").length
    assert_equal "Xen2", concepts[0].find("a").text.strip

    visit untranslated_concepts_path(:lang => :de, :letter => "y", :format => :html)
    concepts = page.all("#content ul")[1].all("li") # XXX: too unspecific

    assert_equal 1, concepts.length
    assert_equal "Yen2", concepts[0].find("a").text.strip
  end

  test "showing error message for thesaurus's main language" do
    visit untranslated_concepts_path(:lang => :en, :letter => "x", :format => :html)

    assert_equal :en, I18n.locale
    assert_equal 1, page.all("#content p.flash_error").length
    assert_equal 0, page.all("#content ul").length
  end

end
