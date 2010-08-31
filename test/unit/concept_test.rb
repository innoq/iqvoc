require 'test_helper'

class ConceptTest < ActiveSupport::TestCase
  def setup
    @current_concept = Factory.create(:concept_with_association)
  end

   def test_should_not_create_more_than_two_versions_of_a_concept
    first_new_concept = Concept.new(@current_concept.attributes)
    second_new_concept = Concept.new(@current_concept.attributes)
    assert(first_new_concept.save!)
    assert_raise ActiveRecord::RecordInvalid do
      second_new_concept.save!
    end
   end

  def test_should_clone_concept_and_associations
    broader_concept = Factory.create(:concept)
    narrower_concept = Factory.create(:concept)
    close_match = Factory.create(:concept)
    @current_concept.broader_relations << Broader.new(:target => broader_concept)
    @current_concept.narrower_relations << Narrower.new(:target => narrower_concept)
    broader_concept.broader_relations << Broader.new(:target => @current_concept)
    broader_concept.save!
    close_match.close_matches << CloseMatch.new(:value => @current_concept)
    close_match.save!
    @current_concept.save!
    @current_concept.reload
    new_concept = @current_concept.clone :include => Concept.associations_for_versioning
    new_concept.increment(:rev)
    assert(new_concept.save!)
    assert_not_equal @current_concept.broader_relations.first.owner_id, new_concept.broader_relations.first.owner_id
    assert_not_equal @current_concept.narrower_relations.first.owner_id, new_concept.narrower_relations.first.owner_id
    assert_equal @current_concept.labelings.size, new_concept.labelings.size
    assert_equal @current_concept.semantic_relations.size, new_concept.semantic_relations.size
    assert_equal @current_concept.referenced_semantic_relations.size, new_concept.referenced_semantic_relations.size
    assert_equal @current_concept.classifications.size, new_concept.classifications.size
    assert_equal @current_concept.matches.size, new_concept.matches.size
    assert_equal @current_concept.referenced_matches.size, new_concept.referenced_matches.size
    assert_equal @current_concept.notes.size, new_concept.notes.size
  end

  def test_should_not_destroy_concept_if_referenced_semantic_relations_exists
    broader_concept = Factory.create(:concept)
    @current_concept.broader_relations << Broader.new(:target => broader_concept)
    @current_concept.save!
    assert(!broader_concept.destroy)
  end

  def test_should_not_destroy_concept_if_match_relations_exists
    close_match = Factory.create(:concept)
    @current_concept.close_matches << CloseMatch.new(:value => close_match)
    @current_concept.save!
    assert(!close_match.destroy)
  end

  def test_should_delete_all_associated_objects_and_the_concept_itself
    label = Factory.create(:label)
    @current_concept.labelings << PrefLabeling.new(:target_id => label.id)
    broader_concept = Factory.create(:concept)
    narrower_concept = Factory.create(:concept)
    @current_concept.broader_relations << Broader.new(:target => broader_concept)
    @current_concept.narrower_relations << Narrower.new(:target => narrower_concept)
    @current_concept.save!
    @current_concept.reload
    @current_concept.collect_first_level_associated_objects.each(&:destroy)
    @current_concept.reload
    assert_equal @current_concept.classifications.size, 0
    assert_equal @current_concept.labelings.size, 0
    assert_equal @current_concept.matches.size, 0
    assert_equal @current_concept.semantic_relations.size, 0
    assert_equal @current_concept.notes.size, 0
    assert(@current_concept.delete)
  end

  def test_should_prepare_concept_for_branching
    @current_concept.prepare_for_branching(1)
    @current_concept.save!
    assert_equal @current_concept.locked_by, 1
    assert_equal @current_concept.published_at, nil
    assert_equal @current_concept.rev, 2
  end

  def test_should_prepare_concept_for_merging
    @current_concept.prepare_for_branching(1)
    @current_concept.save!
    @current_concept.prepare_for_merging
    assert_equal @current_concept.locked_by, nil
  end

  def test_should_create_and_delete_narrower_and_broader_associations
    new_concept = Factory.create(:concept_with_association)
    new_concept_new_version = new_concept.clone :include => Concept.associations_for_versioning
    new_concept_new_version.increment(:rev)
    assert(new_concept_new_version.save!)
    current_concept_narrower_size = @current_concept.narrower_relations.size
    new_concept_broader_size = new_concept.broader_relations.size
    new_concept_new_version_broader_size = new_concept_new_version.broader_relations.size
    @current_concept.narrower_relations.push_with_reflection_creation(Narrower.new(:target_id => new_concept.id))
    assert_equal(current_concept_narrower_size + 2, @current_concept.narrower_relations.reload.size)
    assert_equal(new_concept_broader_size + 1, new_concept.broader_relations.reload.size)
    assert_equal(new_concept_new_version_broader_size + 1, new_concept_new_version.broader_relations.reload.size)

    narrower = Narrower.find_by_owner_id_and_target_id(@current_concept.id, new_concept.id)
    current_concept_narrower_size = @current_concept.narrower_relations.reload.size
    new_concept_broader_size = new_concept.broader_relations.reload.size
    new_concept_new_version_broader_size = new_concept_new_version.broader_relations.reload.size
    @current_concept.narrower_relations.destroy_reflection(narrower)
    assert_equal(current_concept_narrower_size - 2, @current_concept.narrower_relations.reload.size)
    assert_equal(new_concept_broader_size - 1, new_concept.broader_relations.reload.size)
    assert_equal(new_concept_new_version_broader_size - 1, new_concept_new_version.broader_relations.reload.size)
  end

  def test_should_create_and_delete_broader_and_narrower_associations
    new_concept = Factory.create(:concept_with_association)
    new_concept_new_version = new_concept.clone :include => Concept.associations_for_versioning
    new_concept_new_version.increment(:rev)
    assert(new_concept_new_version.save!)
    current_concept_broader_size = @current_concept.broader_relations.size
    new_concept_narrower_size = new_concept.narrower_relations.size
    new_concept_new_version_narrower_size = new_concept_new_version.narrower_relations.size
    @current_concept.broader_relations.push_with_reflection_creation(Broader.new(:target_id => new_concept.id))
    assert_equal(current_concept_broader_size + 2, @current_concept.broader_relations.size)
    assert_equal(new_concept_narrower_size + 1, new_concept.narrower_relations.reload.size)
    assert_equal(new_concept_new_version_narrower_size + 1, new_concept_new_version.narrower_relations.reload.size)

    broader = Broader.find_by_owner_id_and_target_id(@current_concept.id, new_concept.id)
    current_concept_broader_size = @current_concept.broader_relations.reload.size
    new_concept_narrower_size = new_concept.narrower_relations.reload.size
    new_concept_new_version_narrower_size = new_concept_new_version.narrower_relations.reload.size
    @current_concept.broader_relations.destroy_reflection(broader)
    assert_equal(current_concept_broader_size - 2, @current_concept.broader_relations.reload.size)
    assert_equal(new_concept_narrower_size - 1, new_concept.narrower_relations.reload.size)
    assert_equal(new_concept_new_version_narrower_size - 1, new_concept_new_version.narrower_relations.reload.size)
  end

  def test_should_create_and_delete_related_associations
    new_concept = Factory.create(:concept_with_association)
    new_concept_new_version = new_concept.clone :include => Concept.associations_for_versioning
    new_concept_new_version.increment(:rev)
    assert(new_concept_new_version.save!)
    current_concept_related_size = @current_concept.related_relations.size
    new_concept_related_size = new_concept.related_relations.size
    new_concept_new_version_related_size = new_concept_new_version.related_relations.size
    @current_concept.related_relations.push_with_reflection_creation(Related.new(:target_id => new_concept.id))
    assert_equal(current_concept_related_size + 2, @current_concept.related_relations.reload.size)
    assert_equal(new_concept_related_size + 1, new_concept.related_relations.reload.size)
    assert_equal(new_concept_new_version_related_size + 1, new_concept_new_version.related_relations.reload.size)

    related = Related.find_by_owner_id_and_target_id(@current_concept.id, new_concept.id)
    current_concept_related_size = @current_concept.related_relations.reload.size
    new_concept_related_size = new_concept.related_relations.reload.size
    new_concept_new_version_related_size = new_concept_new_version.related_relations.reload.size
    @current_concept.related_relations.destroy_reflection(related)
    assert_equal(current_concept_related_size - 2, @current_concept.related_relations.reload.size)
    assert_equal(new_concept_related_size - 1, new_concept.related_relations.reload.size)
    assert_equal(new_concept_new_version_related_size - 1, new_concept_new_version.related_relations.reload.size)
  end

  def test_should_destroy_reflections
    new_concept = Factory.create(:concept_with_association)
    new_concept_new_version = new_concept.clone :include => Concept.associations_for_versioning
    new_concept_new_version.increment(:rev)
    assert(new_concept_new_version.save!)
    @current_concept.narrower_relations.push_with_reflection_creation(Narrower.new(:target_id => new_concept.id))
    narrower = Narrower.find_by_owner_id_and_target_id(@current_concept.id, new_concept.id)
    current_concept_narrower_size = @current_concept.narrower_relations.reload.size
    new_concept_broader_size = new_concept.broader_relations.reload.size
    new_concept_new_version_broader_size = new_concept_new_version.broader_relations.reload.size
    #assert_raise ActiveRecord::RecordNotFound do
    @current_concept.narrower_relations.destroy_reflection(narrower)
    #end
    assert_equal(current_concept_narrower_size - 2, @current_concept.narrower_relations.reload.size)
    assert_equal(new_concept_broader_size - 1, new_concept.broader_relations.reload.size)
    assert_equal(new_concept_new_version_broader_size - 1, new_concept_new_version.broader_relations.reload.size)
  end

  def test_should_raise_record_not_found
    assert_raise ActiveRecord::RecordNotFound do
      @current_concept.narrower_relations.destroy_reflection(Narrower.new)
    end
  end

  def test_should_not_save_concept_if_pref_label_is_empty
    assert_raise ActiveRecord::RecordInvalid do
      @current_concept.save!(:full_validation => true)
    end
  end

  def test_should_generate_origin
    concept = Factory.build(:concept)
    highest_concept = Concept.find(:first, :select => :origin, :order=> "origin DESC")
    concept.generate_origin
    concept.save!
    assert_equal "_000000" + (highest_concept.origin.to_i+1).to_s, concept.origin
  end
end
