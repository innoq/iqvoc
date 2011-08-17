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

class ConceptTest < ActionDispatch::IntegrationTest

  setup do
    @concept1 = FactoryGirl.create(:concept, :narrower_relations => [])
    @concept2 = FactoryGirl.create(:concept, :narrower_relations => [])
    @concept3 = FactoryGirl.create(:concept, :narrower_relations => [])
  end

  test "showing published concept" do
    visit "/en/concepts/#{@concept1.origin}.html"
    assert page.has_content?("#{@concept1.origin}")
    assert page.has_content?("#{@concept1.pref_label}")
  end

  test "persisting inline relations" do
    login "administrator"

    visit new_concept_path(:lang => "en", :format => "html", :published => 0)
    fill_in "concept_relation_skos_relateds",
        :with => "#{@concept1.origin},#{@concept2.origin},"
    click_button "Save"

    assert page.has_content? I18n.t("txt.controllers.versioned_concept.success")
    assert page.has_css?("#concept_relation_skos_relateds a", :count => 2)

    click_link_or_button I18n.t("txt.views.versioning.to_edit_mode")
    fill_in "concept_relation_skos_relateds", :with => ""
    click_button "Save"

    assert page.has_content? I18n.t("txt.controllers.versioned_concept.update_success")
    assert page.has_no_css?("#concept_relation_skos_relateds a")

    click_link_or_button I18n.t("txt.views.versioning.edit_mode")
    fill_in "concept_relation_skos_relateds",
        :with => "#{@concept1.origin}, #{@concept2.origin}, #{@concept3.origin}"
    click_button "Save"

    assert page.has_content? I18n.t("txt.controllers.versioned_concept.update_success")
    assert page.has_css?("#concept_relation_skos_relateds a", :count => 3)
  end

end
