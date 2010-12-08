require 'test_helper'

class OriginMappingTest < ActiveSupport::TestCase

  def test_should_replace_umlauts
    assert_equal "AeaeUeueOeoess", OriginMapping.merge("ÄäÜüÖöß")
  end

  def test_should_camalize_string
    assert_equal "'A'Weighting", OriginMapping.merge("'A' Weighting")
  end

  def test_should_replace_brackets
    assert_equal "--Energie-Ressource", OriginMapping.merge("[Energie-Ressource]")
  end

  def test_should_replace_comma
    assert_equal "-", OriginMapping.merge(",")
  end

  def test_should_merge_all_together
    assert_equal "--Energie-Ressource", OriginMapping.merge("[Energie - Ressource]")
    assert_equal "--Hydrosphaere-WasserUndGewaesser", OriginMapping.merge("[Hydrosphäre - Wasser und Gewässer]")
  end
end
