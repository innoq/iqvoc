require 'test_helper'

class OriginMappingTest < ActiveSupport::TestCase

  def test_should_replace_umlauts
    assert_equal "AeaeUeueOeoess", OriginMapping.replace_umlauts("ÄäÜüÖöß")
  end

  def test_should_camalize_string
    assert_equal "'A'Weighting", OriginMapping.to_camelcase("'A' Weighting")
  end

  def test_should_replace_brackets
    assert_equal "--Energie - Ressource", OriginMapping.replace_brackets("[Energie - Ressource]")
  end

  def test_should_replace_comma
    assert_equal "-", OriginMapping.replace_commas(",")
  end

  def test_should_merge_all_together
    assert_equal "--Energie-Ressource", OriginMapping.merge("[Energie - Ressource]")
    assert_equal "--Hydrosphaere-WasserUndGewaesser", OriginMapping.merge("[Hydrosphäre - Wasser und Gewässer]")
  end
end
