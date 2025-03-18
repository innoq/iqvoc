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

class CollectionTest < ActionDispatch::IntegrationTest
  test 'collection creation' do
    login('administrator')
    visit dashboard_path(lang: 'en')

    assert page.has_content? 'New Collection'
    click_link_or_button 'New Collection'

    # fill in english pref label
    fill_in 'concept_labelings_by_text_labeling_skos_pref_labels_en', with: 'Test-Collection'

    save_check_and_publish
  end

  test 'send to review with inconsistent concept' do
    login('administrator')
    visit dashboard_path(lang: 'en')
    click_link_or_button 'New Collection'

    # Create invalid preflabel
    fill_in 'concept_labelings_by_text_labeling_skos_pref_labels_en', with: 'Foo,Foo'
    click_link_or_button 'Save'

    # Consistency check should run when sending the collection to review.
    click_link_or_button 'Send to review'
    assert page.has_content? 'Instance is inconsistent.'
  end

  private

  def save_check_and_publish
    click_link_or_button 'Save'

    assert page.has_content? 'The collection has been successfully saved'
    assert page.has_content? 'Current revision 1'

    click_link_or_button 'Check consistency'
    assert page.has_content? 'Instance is consistent.'

    click_link_or_button 'Publish'
    assert page.has_content? 'Instance has been successfully published.'
  end
end
