# encoding: UTF-8

# Copyright 2011-2016 innoQ Deutschland GmbH
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

class ConceptCollectionAssignmentTest < ActionDispatch::IntegrationTest
  setup do
    login 'administrator'

    @sports_coll = Iqvoc::Collection.base_class.new.tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Sports"@en'
      c.publish
      c.save
    end

    @hobbies_coll = Iqvoc::Collection.base_class.new.tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Hobbies"@en'
      c.publish
      c.save
    end
  end

  test 'concept collection assignment' do
    concept = Concept::SKOS::Base.new.tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Testcollection"@en'
      c.publish
      c.save
    end

    visit concept_path(concept, lang: 'en', format: 'html')

    click_link_or_button 'Create new version'
    assert page.has_content? 'Instance copy has been created and locked.'
    collection_origins = [@sports_coll, @hobbies_coll].map(&:origin).join(', ')
    fill_in 'concept_assigned_collection_origins', with: collection_origins
    click_link_or_button 'Save'

    # there should be two collections
    assert_equal 2, page.all('#assigned_collections ul li a').size

    within('#assigned_collections') do
      assert page.has_content? 'Sports'
      assert page.has_content? 'Hobbies'
    end

    # remove hobbies collection
    click_link_or_button 'Continue editing'
    fill_in 'concept_assigned_collection_origins', with: @sports_coll.origin
    click_link_or_button 'Save'

    # there should be one collection left
    assert_equal 1, page.all('#assigned_collections ul li a').size

    within('#assigned_collections') do
      assert page.has_content? 'Sports'
      refute page.has_content? 'Hobbies'
    end

    # remove sports collection, no collection after this
    click_link_or_button 'Continue editing'
    fill_in 'concept_assigned_collection_origins', with: ''
    click_link_or_button 'Save'

    # there should be no collections anymore
    assert_equal 0, page.all('#assigned_collections ul li a').size

    within('#assigned_collections') do
      refute page.has_content?('Sports'), 'Sports should be removed'
      refute page.has_content?('Hobbies'), 'Hobbies should be removed'
    end

  end

end
