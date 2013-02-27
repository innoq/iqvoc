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

class InlineDataTest < ActiveSupport::TestCase

  test "serialization" do
    values = ["foo", "bar"]
    assert_equal "foo, bar",
        Iqvoc::InlineDataHelper.generate_inline_values(values)

    values = ["lorem", "foo, bar", "ipsum"]
    assert_equal 'lorem, "foo, bar", ipsum',
        Iqvoc::InlineDataHelper.generate_inline_values(values)
  end

  test "deserialization" do
    inline_values = "foo, bar"
    assert_equal ["foo", "bar"],
        Iqvoc::InlineDataHelper.parse_inline_values(inline_values)

    inline_values = 'lorem, "foo, bar", ipsum'
    assert_equal ["lorem", "foo, bar", "ipsum"],
        Iqvoc::InlineDataHelper.parse_inline_values(inline_values)

    inline_values = 'lorem,"foo, bar",ipsum'
    assert_equal ["lorem", "foo, bar", "ipsum"],
        Iqvoc::InlineDataHelper.parse_inline_values(inline_values)

    inline_values = 'foo, bar,baz' # inconsistent whitespace
    assert_equal ["foo", "bar", "baz"],
        Iqvoc::InlineDataHelper.parse_inline_values(inline_values)

    inline_values = 'lorem,"foo, bar", ipsum' # inconsistent whitespace
    assert_equal ["lorem", "foo, bar", "ipsum"],
        Iqvoc::InlineDataHelper.parse_inline_values(inline_values)

    inline_values = 'lorem, "foo, bar",ipsum' # inconsistent whitespace
    assert_raises(CSV::MalformedCSVError) do
      Iqvoc::InlineDataHelper.parse_inline_values(inline_values)
    end

    inline_values = ''
    assert_equal [], Iqvoc::InlineDataHelper.parse_inline_values(inline_values)
  end

end
