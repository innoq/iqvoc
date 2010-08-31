require 'test_helper'

class OriginMappingTest < ActiveSupport::TestCase
  def setup
   @origin = OriginMapping.new
  end

  def test_should_replace_umlauts
    assert_equal "AeaeUeueOeoess", @origin.replace_umlauts("ÄäÜüÖöß")
  end

  def test_should_camalize_string
    assert_equal "'A'Weighting", @origin.to_camelcase("'A' Weighting")
  end

  def test_should_replace_brackets
    assert_equal "--Energie - Ressource", @origin.replace_brackets("[Energie - Ressource]")
  end

  def test_should_replace_comma
    assert_equal "-", @origin.replace_commas(",")
  end

  def test_should_merge_all_together
    assert_equal "--Energie-Ressource", @origin.merge("[Energie - Ressource]")
    assert_equal "--Hydrosphaere-WasserUndGewaesser", @origin.merge("[Hydrosphäre - Wasser und Gewässer]")
  end
end
