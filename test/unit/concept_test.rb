require 'test_helper'

class ConceptTest < ActiveSupport::TestCase
  def setup
    @current_concept = Factory.create(:concept_with_associations)
  end

  test "should not create more than two versions of a concept" do
    first_new_concept  = Concept::Base.new(@current_concept.attributes)
    second_new_concept = Concept::Base.new(@current_concept.attributes)
    assert first_new_concept.save
    assert_equal second_new_concept.save, false
  end

  test "should not save concept with empty preflabel" do
    assert_raise ActiveRecord::RecordInvalid do
      Factory.create(:concept, :labelings => []).save_with_full_validation!
    end
  end

  test "should generate origin" do
    concept = Factory.build(:concept)
    highest_concept = Concept::Base.select(:origin).order("origin DESC").first
    concept.generate_origin
    concept.save!
    assert_equal sprintf("_%08d", highest_concept.origin.to_i + 1), concept.origin
  end
end
