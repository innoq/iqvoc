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

class ConceptSchemeTest < ActiveSupport::TestCase
  test "singleton concept scheme" do
    assert_equal 0, Concept::SKOS::Scheme.count

    assert_difference 'Concept::SKOS::Scheme.count' do
      Concept::SKOS::Scheme.instance
    end

    assert_no_difference 'Concept::SKOS::Scheme.count' do
      Concept::SKOS::Scheme.instance
    end

    assert_raise TypeError do
      Concept::SKOS::Scheme.create
    end
  end
end
