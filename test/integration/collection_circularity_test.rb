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

require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

class CollectionCircularityTest < ActionDispatch::IntegrationTest

  setup do
    @coll1 = FactoryGirl.create(:collection)
    @coll2 = FactoryGirl.create(:collection)
    @coll3 = FactoryGirl.create(:collection)
    @concept1 = FactoryGirl.create(:concept)
    @concept2 = FactoryGirl.create(:concept)
    @concept3 = FactoryGirl.create(:concept)
  end

  test "inline assignments are persisted" do
    login("administrator")

    delimiter = "," # without space

    visit edit_collection_path(@coll1, :lang => "en", :format => "html")
    fill_in "concept_inline_member_collection_origins",
        :with => [@coll2.origin, @coll3.origin].join(delimiter)
    fill_in "concept_inline_member_concept_origins",
        :with => [@concept1.origin, @concept2.origin, @concept3.origin].join(delimiter)
    click_button "Save"

    assert page.has_no_css?(".flash_error")
    assert page.has_content?(I18n.t("txt.controllers.collections.save.success"))
    assert page.has_link?(@coll2.pref_label.to_s)
    assert page.has_link?(@coll3.pref_label.to_s)
    assert page.has_link?(@concept1.pref_label.to_s)
    assert page.has_link?(@concept2.pref_label.to_s)
    assert page.has_link?(@concept3.pref_label.to_s)

    click_link_or_button "Edit"
    fill_in "concept_inline_member_collection_origins", :with => ""
    fill_in "concept_inline_member_concept_origins", :with => ""
    click_button "Save"

    assert page.has_no_css?(".flash_error")
    assert page.has_content?(I18n.t("txt.controllers.collections.save.success"))
    assert page.has_no_link?(@coll2.pref_label.to_s)
    assert page.has_no_link?(@coll3.pref_label.to_s)
    assert page.has_no_link?(@concept1.pref_label.to_s)
    assert page.has_no_link?(@concept2.pref_label.to_s)
    assert page.has_no_link?(@concept3.pref_label.to_s)

    delimiter = ", " # with space

    click_link_or_button "Edit"
    fill_in "concept_inline_member_collection_origins",
        :with => [@coll2.origin, @coll3.origin].join(delimiter)
    fill_in "concept_inline_member_concept_origins",
        :with => [@concept1.origin, @concept2.origin, @concept3.origin].join(delimiter)
    click_button "Save"

    assert page.has_no_css?(".flash_error")
    assert page.has_content?(I18n.t("txt.controllers.collections.save.success"))
    assert page.has_link?(@coll2.pref_label.to_s)
    assert page.has_link?(@coll3.pref_label.to_s)
    assert page.has_link?(@concept1.pref_label.to_s)
    assert page.has_link?(@concept2.pref_label.to_s)
    assert page.has_link?(@concept3.pref_label.to_s)
  end

  test "circular sub-collection references are rejected during update" do
    login("administrator")

    # add coll2 as subcollection of coll1
    visit edit_collection_path(@coll1, :lang => "en", :format => "html")
    fill_in "concept_inline_member_collection_origins",
        :with => "%s," % @coll2.origin
    click_button "Save"

    assert page.has_no_css?(".flash_error")
    assert page.has_content?(I18n.t("txt.controllers.collections.save.success"))
    assert page.has_link?(@coll2.pref_label.to_s,
        :href => collection_path(@coll2, :lang => "en", :format => "html"))

    # add coll1 as subcollection of coll2
    visit edit_collection_path(@coll2, :lang => "en", :format => "html")
    fill_in "concept_inline_member_collection_origins",
        :with => "%s," % @coll1.origin
    click_button "Save"

    assert page.has_css?(".alert-danger")
    assert page.has_css?("#edit_concept")
    assert page.has_content?( # XXX: page.has_content? didn't work
        I18n.t("txt.controllers.collections.circular_error", :label => @coll1.pref_label))

    # ensure coll1 is not a subcollection of coll2
    visit collection_path(@coll2, :lang => "en", :format => "html")
    assert page.has_no_css?(".relation ul.treeview li") # XXX: too unspecific
  end
end
