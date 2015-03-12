# encoding: UTF-8

# Copyright 2011-2015 innoQ Deutschland GmbH
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

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class DeepCloningTest < ActiveSupport::TestCase
  setup do
    @admin = User.create! do |u|
      u.forename = 'Test'
      u.surname = 'User'
      u.email = 'admin@iqvoc'
      u.password = 'omgomgomg'
      u.password_confirmation = 'omgomgomg'
      u.role = 'administrator'
      u.active = true
    end

    # Concept hierarchy for testing
    #
    # + Achievement Hobbies
    #   - Air Sport
    # + Sports
    @child_concept = Iqvoc::Concept.base_class.new.tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Child Concept"@en'
      c.publish
      c.save
    end

    @root_concept1 = Iqvoc::Concept.base_class.new(top_term: true, origin: 'root_concept1').tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Root Concept 1"@en'
      RDFAPI.devour c, 'skos:narrower', @child_concept
      c.publish
      c.save
    end

    @root_concept2 = Iqvoc::Concept.base_class.new(top_term: true, origin: 'root_concept2').tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Root Concept 2"@en'
      c.publish
      c.save
    end

    @sub_collection = Iqvoc::Collection.base_class.new(origin: 'sub_collection').tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Sub Collection"@en'
      c.publish
      c.save
    end

    @root_collection = Iqvoc::Collection.base_class.new(origin: 'root_collection1').tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Root Collection"@en'
      RDFAPI.devour c, 'skos:member', @root_concept1
      RDFAPI.devour c, 'skos:member', @root_concept2
      RDFAPI.devour c, 'skos:member', @child_concept
      RDFAPI.devour c, 'skos:member', @sub_collection
      c.publish
      c.save
    end

  end

  def after_setup
    assert_equal 1, @root_concept1.narrower_relations.size
    assert_equal @child_concept, @root_concept1.narrower_relations.first.target

    assert_equal 1, @child_concept.broader_relations.size
    assert_equal @root_concept1, @child_concept.broader_relations.first.target

    assert_equal 3, @root_collection.concepts.size
    assert_equal [@root_concept1, @root_concept2, @child_concept], @root_collection.concepts

    assert_equal 1, @root_collection.subcollections.size
    assert_equal @sub_collection, @root_collection.subcollections.first
  end

  test 'should deep clone concept' do
    root_concept_dup = @root_concept1.branch @admin
    root_concept_dup.save

    # test narrower
    assert_equal 1, root_concept_dup.narrower_relations.size
    assert_equal @child_concept, root_concept_dup.narrower_relations.first.target

    # test broader
    assert_equal 2, @child_concept.broader_relations.size
    assert_equal 1, @child_concept.broader_relations.published.size
    assert_equal @root_concept1, @child_concept.broader_relations.published.first.target
    assert_equal root_concept_dup, @child_concept.broader_relations.unpublished.first.target

    # test parent collection
    assert_equal @root_collection, root_concept_dup.collections.first
  end

  test 'should deep clone collection' do
    root_collection_dup = @root_collection.branch @admin
    root_collection_dup.save

    # test subcollections
    assert_equal 1, root_collection_dup.subcollections.size

    # test parent collections
    assert_equal 1, @sub_collection.parent_collections.unpublished.size
    assert_equal root_collection_dup, @sub_collection.parent_collections.unpublished.first

    # test collections members
    assert_equal 3, root_collection_dup.concepts.size
  end

end
