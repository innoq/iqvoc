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

class ConceptLabelLanguageTest < ActionDispatch::IntegrationTest

  setup do
    # create a few XL labels
    @labels = {}
    {
      "English" => "en",
      "Deutsch" => "de"
    }.each { |name, lang|
      @labels[name] = Factory.create(:xllabel, :origin => "_#{name}",
          :language => lang, :value => name, :published_at => Time.now)
    }
  end

  test "invalid alt label languages are rejected" do
    login("administrator")

    visit new_concept_path(:lang => "de", :format => "html")
    # NB: label language does not match relation language
    fill_in "labeling_skosxl_alt_labels_en",
        :with => "#{@labels["Deutsch"].origin},"
    click_button "Speichern"

    assert page.has_css?(".flash_error")
    assert page.has_css?("#concept_new")
    assert page.source.include?( # XXX: page.has_content? didn't work
        I18n.t("txt.controllers.versioned_concept.label_error") % "Deutsch")

    # ensure concept was not saved
    visit dashboard_path(:lang => "de", :format => "html")
    assert page.has_no_css?("td")
  end

  test "invalid pref label languages are rejected during creation" do
    login("administrator")

    visit new_concept_path(:lang => "de", :format => "html")
    # NB: label language does not match relation language
    fill_in "labeling_skosxl_pref_labels_de",
        :with => "#{@labels["English"].origin},"
    click_button "Speichern"

    assert page.has_css?(".flash_error")
    assert page.has_css?("#concept_new")
    assert page.source.include?( # XXX: page.has_content? didn't work
        I18n.t("txt.controllers.versioned_concept.label_error") % "English")

    # ensure concept was not saved
    visit dashboard_path(:lang => "de", :format => "html")
    assert page.has_no_css?("td")
  end

  test "invalid label languages are rejected during update" do
    login("administrator")

    # create, then edit concept
    visit new_concept_path(:lang => "de", :format => "html")
    click_button "Speichern"
    visit dashboard_path(:lang => "de", :format => "html")
    page.find("td a").click
    page.click_link_or_button "In Bearbeitung versetzen"

    # NB: label languages do not match relation languages
    fill_in "labeling_skosxl_pref_labels_de",
        :with => "#{@labels["English"].origin},"
    fill_in "labeling_skosxl_alt_labels_en",
        :with => "#{@labels["Deutsch"].origin},"
    click_button "Speichern"

    assert page.has_css?(".flash_error")
    assert page.has_css?("#concept_edit")
    assert page.source.include?( # XXX: page.has_content? didn't work
        I18n.t("txt.controllers.versioned_concept.label_error") % "English")
    assert page.source.include?( # XXX: page.has_content? didn't work
        I18n.t("txt.controllers.versioned_concept.label_error") % "Deutsch")
  end
end
