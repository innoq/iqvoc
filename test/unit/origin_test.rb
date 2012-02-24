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

class OriginTest < ActiveSupport::TestCase

  def test_should_replace_umlauts
    assert_equal "AeaeUeueOeoess", Iqvoc::Origin.new("ÄäÜüÖöß").to_s
  end

  def test_should_camalize_string
    assert_equal "AWeighting", Iqvoc::Origin.new("'A' Weighting").to_s
  end

  def test_should_handle_numbers_at_the_beginning
    assert_equal "_123", Iqvoc::Origin.new("123").to_s
  end

  def test_should_handle_whitespaces_at_strange_positions
    assert_equal "test12", Iqvoc::Origin.new("test 12 ").to_s
  end

  def test_should_preserve_underlines
    assert_equal "_test", Iqvoc::Origin.new("_test").to_s
    assert_equal "a_Test", Iqvoc::Origin.new("a_Test").to_s
  end

  def test_should_preserve_case
    assert_equal "test", Iqvoc::Origin.new("test").to_s
    assert_equal "Test", Iqvoc::Origin.new("Test").to_s
    assert_equal "_5test", Iqvoc::Origin.new("5test").to_s
    assert_equal "_5Test", Iqvoc::Origin.new("5Test").to_s
  end

  def test_should_replace_brackets
    assert_equal "--Energie-Ressource", Iqvoc::Origin.new("[Energie/Ressource]").to_s
  end

  def test_should_replace_comma
    assert_equal "-", Iqvoc::Origin.new(",").to_s
  end

  def test_should_merge_all_together
    assert_equal "--Energie-Ressource", Iqvoc::Origin.new("[Energie - Ressource]").to_s
    assert_equal "--Hydrosphaere-WasserUndGewaesser", Iqvoc::Origin.new("[Hydrosphäre - Wasser und Gewässer]").to_s
  end

  def test_sanitize_for_base_form
    assert_equal "commaslashdotbracketbracket", Iqvoc::Origin.new("comma,slash/dot.bracket[bracket]").sanitize_for_base_form!.to_s
  end

end
