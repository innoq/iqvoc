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
    [ {:en => "Xen1", :de => "Xde1"},
      {:en => "Xen2"},
      {:en => "Yen1", :de => "Yde1"},
      {:en => "Yen2"}
    ].map do |hsh|
      labelings = []
      hsh.each do |lang, val|
        labelings << Factory(:pref_labeling, :target => Factory(:pref_label, :language => lang, :value => val))
      end
      FactoryGirl.create(:concept, :pref_labelings => labelings)
    end
  end

  # FIXME: apparently these tests are bogus, as they passed even when they
  # should fail (see the commit that introduced this very comment for details)

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
