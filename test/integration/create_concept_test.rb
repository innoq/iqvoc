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

class CreateConceptTest < ActionDispatch::IntegrationTest
  test 'concept creation' do
    login('administrator')
    visit dashboard_path(lang: 'en')

    assert page.has_content? 'New Concept'
    click_link_or_button 'New Concept'

    # fill in english pref label
    fill_in 'concept_labelings_by_text_labeling_skos_pref_labels_en', with: 'Foo'

    save_check_and_publish
  end

  test 'concept creation with match relation' do
    Iqvoc.config['sources.iqvoc'] = ['http://try.iqvoc.net']

    login('administrator')
    visit dashboard_path(lang: 'en')

    assert page.has_content? 'New Concept'
    click_link_or_button 'New Concept'

    # fill in english pref label
    fill_in 'concept_labelings_by_text_labeling_skos_pref_labels_en', with: 'Bar'

    # fill in match
    fill_in 'concept_inline_match_skos_close_matches', with: 'http://try.iqvoc.net/air_sports'

    save_check_and_publish

    @bar = Iqvoc::Concept.base_class.last
    assert_equal 1, @bar.jobs.size, 1
  end

  private

  def save_check_and_publish
    click_link_or_button 'Save'

    assert page.has_content? 'Concept has been successfully created.'
    assert page.has_content? 'Current revision 1'

    click_link_or_button 'Check consistency'
    assert page.has_content? 'Instance is consistent.'

    click_link_or_button 'Publish'
    assert page.has_content? 'Instance has been successfully published.'
  end
end
