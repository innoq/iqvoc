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
    assert_raise ActiveRecord::RecordInvalid do
      Factory.create(:concept, :labelings => []).save_with_full_validation!
    end
  end

  test "should generate origin" do
    concept = Factory.build(:concept)
    highest_concept = Concept::Base.select(:origin).order("origin DESC").first
    concept.generate_origin
    concept.save!
    assert_equal sprintf("_%08d", highest_concept.origin.to_i + 1), concept.origin
  end
end
