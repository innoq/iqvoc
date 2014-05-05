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

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class FoobarStripper < Iqvoc::Origin::Filters::GenericFilter
  def call(obj, str)
    str = str.gsub("foobar", "")
    run(obj, str)
  end
end

class OriginTest < ActiveSupport::TestCase

  def test_should_replace_umlauts
    assert_equal "aauuooss", Iqvoc::Origin.new("ÄäÜüÖöß").to_s
  end

  def test_should_camelize_string
    assert_equal "a-weighting", Iqvoc::Origin.new("'A' Weighting").to_s
  end

  def test_should_handle_numbers_at_the_beginning
    assert_equal "_123", Iqvoc::Origin.new("123").to_s
  end

  def test_should_handle_whitespaces_at_strange_positions
    assert_equal "test-12", Iqvoc::Origin.new("test 12 ").to_s
  end

  def test_should_preserve_underlines
    assert_equal "_test", Iqvoc::Origin.new("_test").to_s
    assert_equal "a_test", Iqvoc::Origin.new("a_Test").to_s
  end

  def test_should_preserve_case
    assert_equal "test", Iqvoc::Origin.new("test").to_s
    assert_equal "test", Iqvoc::Origin.new("Test").to_s
    assert_equal "_5test", Iqvoc::Origin.new("5test").to_s
    assert_equal "_5test", Iqvoc::Origin.new("5Test").to_s
  end

  def test_should_replace_brackets
    assert_equal "energie-ressource",
      Iqvoc::Origin.new("[Energie/Ressource]").to_s
  end

  def test_should_replace_comma
    assert_equal "ab-cd", Iqvoc::Origin.new("ab,cd").to_s
  end

  def test_should_replace_less_and_greater_chars
    assert_equal "test-123", Iqvoc::Origin.new("Test<123").to_s
    assert_equal "test-123", Iqvoc::Origin.new("Test>123").to_s
  end

  def test_should_merge_all_together
    assert_equal "energie-ressource",
      Iqvoc::Origin.new("[Energie - Ressource]").to_s
    assert_equal "hydrosphare-wasser-und-gewasser",
      Iqvoc::Origin.new("[Hydrosphäre - Wasser und Gewässer]").to_s
    assert_equal "_12-hydrosphare-wasser-und-gewasser",
      Iqvoc::Origin.new("12[Hydrosphäre - Wasser und Gewässer]").to_s
  end

  def test_register_custom_filter
    Iqvoc::Origin::Filters.register(:strip_foobars, FoobarStripper)
    assert_equal "trololo_", Iqvoc::Origin.new("trololo_foobar").strip_foobars.to_s
    assert_equal "trololo_", Iqvoc::Origin.new("trololo_foobar").to_s
  end

end
