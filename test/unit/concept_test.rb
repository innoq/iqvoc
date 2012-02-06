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

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class ConceptTest < ActiveSupport::TestCase

  setup do
    @current_concept = FactoryGirl.create(:concept)
  end

  test "should not create more than two versions of a concept" do
    first_new_concept  = Concept::Base.new(@current_concept.attributes)
    second_new_concept = Concept::Base.new(@current_concept.attributes)
    assert first_new_concept.save
    assert_equal second_new_concept.save, false
  end

  test "should not save concept with empty preflabel" do
    FactoryGirl.create(:concept).save_with_full_validation! # Is the factory working as expected?
    assert_raise ActiveRecord::RecordInvalid do
      FactoryGirl.create(:concept, :pref_labelings => []).save_with_full_validation!
    end
  end

  test "concepts without pref_labels should be saveable but not publishable" do
    concept =  FactoryGirl.create(:concept, :pref_labelings => [])
    assert_equal [], concept.pref_labels
    assert concept.valid?
    assert !concept.valid_with_full_validation?
  end

  test "published concept must have a pref_label of the first pref_label language configured (the main language)" do
    concept = FactoryGirl.create(:concept)
    assert_equal 1, concept.pref_labels.count
    assert concept.valid_with_full_validation?

    concept.pref_labels.first.language = Iqvoc::Concept.pref_labeling_languages.second
    assert !concept.valid_with_full_validation?
  end

  test "concept shouldn't have more then one pref label of the same language" do
    concept = FactoryGirl.create(:concept)
    assert concept.valid?
    concept.pref_labelings << FactoryGirl.build(:pref_labeling)
    assert_equal 2, concept.pref_labelings.count
    assert_equal concept.pref_labelings.first.target.language, concept.pref_labelings.second.target.language
    assert concept.invalid?
  end

  test "concepts can have multiple preferred labels" do
    concept = FactoryGirl.build(:concept)
    concept.labelings << FactoryGirl.build(:pref_labeling, :target => Factory(:pref_label, :language => Iqvoc::Concept.pref_labeling_languages.second))
    concept.save!
    concept.reload

    assert_equal 2, concept.pref_labels.count
    assert_not_equal concept.pref_labels.first.language, concept.pref_labels.second.language
    assert concept.valid_with_full_validation?
  end

  test "labelings_by_text setter" do
    concept = FactoryGirl.build(:concept, :pref_labelings => [])

    concept.labelings_by_text = {
      Iqvoc::Concept.pref_labeling_class_name.to_relation_name => {Iqvoc::Concept.pref_labeling_languages.first => 'A new label'}
    }
    assert concept.valid?
    assert concept.save
    concept.reload
    assert_equal 'A new label', concept.pref_label.value
    assert_equal Iqvoc::Concept.pref_labeling_languages.first, concept.pref_label.language.to_s

    concept.labelings_by_text = {
      Iqvoc::Concept.pref_labeling_class_name.to_relation_name => {Iqvoc::Concept.pref_labeling_languages.first => 'A new label, Another Label in the same language'}
    }
    assert !concept.save
  end

end
