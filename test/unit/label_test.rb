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

class LabelTest < ActiveSupport::TestCase
  def setup
    @concept1 = Factory.create(:concept)
    @concept2 = Factory.create(:concept)
    Iqvoc::Concept.further_labeling_classes.first.first.create!(:owner => @concept1, :target => @concept2.pref_label) # Assign the pref_label of @concept2 as AltLabel to @concept1
  end

  test "relations" do
    label = @concept2.pref_label
    assert_not_nil label
    assert_equal [@concept1.id, @concept2.id].sort, label.concepts.map(&:id).sort
    assert_equal [@concept2.id].sort, label.pref_labeled_concepts.map(&:id).sort
  end

end
