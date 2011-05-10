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

class ConceptTest < ActiveSupport::TestCase
  def setup
    @current_concept = Factory.create(:concept)
  end

  test "should not create more than two versions of a concept" do
    first_new_concept  = Concept::Base.new(@current_concept.attributes)
    second_new_concept = Concept::Base.new(@current_concept.attributes)
    assert first_new_concept.save
    assert_equal second_new_concept.save, false
  end

  test "should not save concept with empty preflabel" do
    Factory.create(:concept).save_with_full_validation! # Is the factory working as expected?
    assert_raise ActiveRecord::RecordInvalid do
      Factory.create(:concept, :labelings => []).save_with_full_validation!
    end
  end

  test "should generate origin" do
    concept = Factory.build(:concept)
    highest_concept = Concept::Base.select(:origin).order("origin DESC").first
    concept.generate_origin
    concept.save!
    assert concept.origin =~ /^_([0-9]+)$/
    assert $1.to_i > highest_concept.origin.to_i
  end

  test "concepts without pref_labels should be saveable but not publishable" do
    concept =  Factory.create(:concept, :labelings => [])
    assert_equal [], concept.pref_labels
    assert concept.valid?
    assert !concept.valid_with_full_validation?
  end

  test "pref_labels must have valid languages" do
    concept = Factory.create(:concept)
    assert_equal 1, concept.pref_labels.count
    assert concept.valid_with_full_validation?

    concept.pref_labels.first.language = "öö"
    assert !concept.valid?
  end

  test "published concept must have a pref_label of the first pref_label language configured (the main language)" do
    concept = Factory.create(:concept)
    assert_equal 1, concept.pref_labels.count
    assert concept.valid_with_full_validation?

    concept.pref_labels.first.language = Iqvoc::Concept.pref_labeling_languages.second
    assert !concept.valid_with_full_validation?
  end

  test "concept shouldn't have more then one pref label of the same language" do
    concept = Factory.build(:concept)
    assert concept.valid?
    concept.labelings << Factory.build(:pref_labeling)
    concept.save!
    concept.reload

    assert_equal 2, concept.pref_labels.count
    assert_equal concept.pref_labels.first.language, concept.pref_labels.second.language
    assert !concept.valid?
  end

  test "concepts can have multiple preferred labels" do
    concept = Factory.build(:concept)
    concept.labelings << Factory.build(:pref_labeling, :target => Factory(:pref_label, :language => Iqvoc::Concept.pref_labeling_languages.second))
    concept.save!
    concept.reload

    assert_equal 2, concept.pref_labels.count
    assert_not_equal concept.pref_labels.first.language, concept.pref_labels.second.language
    assert concept.valid_with_full_validation?
  end

end
