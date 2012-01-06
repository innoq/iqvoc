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

class OriginMappingTest < ActiveSupport::TestCase

  def test_should_replace_umlauts
    assert_equal "AeaeUeueOeoess", OriginMapping.merge("ÄäÜüÖöß")
  end

  def test_should_camalize_string
    assert_equal "AWeighting", OriginMapping.merge("'A' Weighting")
  end

  def test_should_handle_numbers_at_the_beginning
    assert_equal "_123", OriginMapping.merge("123")
  end

  def test_should_handle_whitespaces_at_strange_positions
    assert_equal "test12", OriginMapping.merge("test 12 ")
  end

  def test_should_preserve_underlines
    assert_equal "_test", OriginMapping.merge("_test")
    assert_equal "a_Test", OriginMapping.merge("a_Test")
  end

  def test_should_preserve_case
    assert_equal "test", OriginMapping.merge("test")
    assert_equal "Test", OriginMapping.merge("Test")
    assert_equal "_5test", OriginMapping.merge("5test")
    assert_equal "_5Test", OriginMapping.merge("5Test")
  end

  def test_should_replace_brackets
    assert_equal "--Energie-Ressource", OriginMapping.merge("[Energie/Ressource]")
  end

  def test_should_replace_comma
    assert_equal "-", OriginMapping.merge(",")
  end

  def test_should_merge_all_together
    assert_equal "--Energie-Ressource", OriginMapping.merge("[Energie - Ressource]")
    assert_equal "--Hydrosphaere-WasserUndGewaesser", OriginMapping.merge("[Hydrosphäre - Wasser und Gewässer]")
  end

    def test_sanitize_for_base_form
      assert_equal "commaslashdotbracketbracket", OriginMapping.sanitize_for_base_form("comma,slash/dot.bracket[bracket]")
    end

end
