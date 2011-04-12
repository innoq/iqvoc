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
    @current_label = Factory.create(:xllabel_with_association)
    @user = Factory.create(:user)
  end

  def test_should_not_create_more_than_two_versions_of_a_label
    first_new_label = Label::SKOSXL::Base.new(@current_label.attributes)
    second_new_label = Label::SKOSXL::Base.new(@current_label.attributes)
    assert first_new_label.save
    assert_equal second_new_label.save, false
  end
  
end
