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

class CollectionCircularityTest < ActionDispatch::IntegrationTest

  test "circular sub-collection references are rejected during update" do
    coll1 = Factory.create(:collection)
    coll2 = Factory.create(:collection)

    login("administrator")

    # add coll2 as subcollection of coll1
    visit edit_collection_path(coll1, :lang => "de", :format => "html")
    fill_in "concept_inline_member_collection_origins",
        :with => "%s," % coll2.origin
    click_button "Speichern"

    assert page.has_no_css?(".flash_error")
    assert page.has_content?(I18n.t("txt.controllers.collections.save.success"))
    assert page.has_link?(coll2.label.to_s,
        :href => collection_path(coll2, :lang => "de", :format => "html"))

    # add coll1 as subcollection of coll2
    visit edit_collection_path(coll2, :lang => "de", :format => "html")
    fill_in "concept_inline_member_collection_origins",
        :with => "%s," % coll1.origin
    click_button "Speichern"

    assert page.has_css?(".flash_error")
    assert page.has_css?("#concept_edit")
    assert page.source.include?( # XXX: page.has_content? didn't work
        I18n.t("txt.controllers.collections.circular_error") % coll1.label)

    # ensure coll1 is not a subcollection of coll2
    visit collection_path(coll2, :lang => "de", :format => "html")
    assert page.has_no_link?(coll1.label.to_s)
  end
end
