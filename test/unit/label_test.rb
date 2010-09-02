require 'test_helper'

class LabelTest < ActiveSupport::TestCase
  def setup
    @current_label = Factory.create(:label_with_association)
    @user = Factory.create(:user)
  end

  def test_should_not_create_more_than_two_versions_of_a_label
    first_new_label = Label.new(@current_label.attributes)
    second_new_label = Label.new(@current_label.attributes)
    assert(first_new_label.save!)
    assert_raise ActiveRecord::RecordInvalid do
      second_new_label.save!
    end
  end

  def test_should_clone_label_and_associations
    new_label = @current_label.clone :include => Label.associations_for_versioning
    new_label.increment(:rev)
    assert(new_label.save!)
    assert_equal @current_label.qualifiers.size, new_label.qualifiers.size
    assert_equal @current_label.translations.size, new_label.translations.size
    assert_equal @current_label.labelings.size, new_label.labelings.size
    assert_equal @current_label.inflectionals.size, new_label.inflectionals.size
    assert_equal @current_label.label_relations.size, new_label.label_relations.size
    assert_equal @current_label.reverse_compound_form_contents.size, new_label.reverse_compound_form_contents.size
    assert_equal @current_label.notes.size, new_label.notes.size
    # +2 because of the 2 Change Note - note_annotations that get created in the after_branch Callback
    assert_equal @current_label.note_annotations.size + 2, new_label.note_annotations.size
    assert_equal @current_label.compound_forms.size, new_label.compound_forms.size
    assert_equal @current_label.compound_form_contents.size, new_label.compound_form_contents.size
  end

  def test_should_clone_label_and_many_associations
    current_label = Factory.create(:label_with_many_association)
    concept = Factory.create(:concept)
    #Generates a few associations :-)
    5.times do
      current_label.homographs << UMT::Homograph.new(:range_id => @current_label.id)
      current_label.qualifiers << UMT::Qualifier.new(:range_id => @current_label.id)
      current_label.umt_source_notes << UMT::SourceNote.new(:owner_type => "Label")
      current_label.compound_forms << UMT::CompoundForm.new
      concept.pref_labelings << PrefLabeling.new(:target_id => current_label.id)
    end
    current_label.save!
    concept.save!
    #Generates a few note annotations :-)
    current_label.notes.each do |note|
      note.note_annotations << NoteAnnotation.new
      note.save!
    end
    current_label.reload
    new_label = current_label.clone :include => Label.associations_for_versioning
    new_label.save!
    new_label.increment(:rev)
    assert_equal current_label.labelings.size, new_label.labelings.size
    assert_equal current_label.inflectionals.size, new_label.inflectionals.size
    assert_equal current_label.label_relations.size, new_label.label_relations.size
    assert_equal current_label.reverse_compound_form_contents.size, new_label.reverse_compound_form_contents.size
    assert_equal current_label.notes.size, new_label.notes.size
    assert_equal current_label.note_annotations.size, new_label.note_annotations.size
    assert_equal current_label.compound_forms.size, new_label.compound_forms.size
    assert_equal current_label.compound_form_contents.size, new_label.compound_form_contents.size
  end

  def test_should_not_destroy_label_if_referenced_label_relations_exists
    second_label = Factory.create(:label_with_association)
    @current_label.homographs << UMT::Homograph.new(:range_id => second_label.id)
    @current_label.save!
    assert(!second_label.destroy)
  end

  def test_should_not_destroy_label_if_pref_labelings_exists
    concept = Factory.create(:concept)
    concept.pref_labelings << PrefLabeling.new(:target_id => @current_label.id)
    concept.save!
    assert(!@current_label.destroy)
  end

  def test_should_delete_all_associated_objects_and_the_label_itself
    @current_label.collect_first_level_associated_objects.each(&:destroy)
    @current_label.reload
    assert_equal @current_label.labelings.size, 0
    assert_equal @current_label.inflectionals.size, 0
    assert_equal @current_label.label_relations.size, 0
    assert_equal @current_label.reverse_compound_form_contents.size, 0
    assert_equal @current_label.notes.size, 0
    assert_equal @current_label.note_annotations.size, 0
    assert_equal @current_label.compound_forms.size, 0
    assert_equal @current_label.compound_form_contents.size, 0
    assert(@current_label.delete)
  end

  def test_should_prepare_label_for_branching
    @current_label.prepare_for_branching(@user.id)
    @current_label.save!
    assert_equal @current_label.locking_user, @user
    assert_equal @current_label.published_at, nil
    assert_equal @current_label.rev, 2
  end

  def test_should_prepare_label_for_merging
    @current_label.prepare_for_branching(@user.id)
    @current_label.save!
    assert @current_label.branched?
    @current_label.prepare_for_merging
    assert_equal @current_label.locked_by, nil
  end

  def test_should_not_saving_label_if_only_homograph_exists
    current_label = Factory.create(:label)
    current_label.homographs << UMT::Homograph.new(:range_id => @current_label.id)
    current_label.prepare_for_branching(@user.id)
    current_label.save!
    assert current_label.branched?
    current_label.prepare_for_merging
    assert_raise ActiveRecord::RecordInvalid do
      current_label.save_with_full_validation!
    end
  end

  def test_should_not_saving_label_if_only_qualifier_exists
    current_label = Factory.create(:label)
    current_label.qualifiers << UMT::Qualifier.new(:range_id => @current_label.id)
    current_label.prepare_for_branching(@user.id)
    current_label.save!
    assert current_label.branched?
    current_label.prepare_for_merging
    assert_raise ActiveRecord::RecordInvalid do
      current_label.save_with_full_validation!
    end
  end

  def test_should_not_saving_label_if_none_compound_form_content_exist
    current_label = Factory.create(:label)
    current_label.compound_forms << UMT::CompoundForm.new
    current_label.prepare_for_branching(@user.id)
    current_label.save!
    assert current_label.branched?
    current_label.prepare_for_merging
    assert_raise ActiveRecord::RecordInvalid do
      current_label.save_with_full_validation!
    end
  end

  def test_should_not_saving_label_if_only_one_compound_form_content_exist
    current_label = Factory.create(:label)
    current_label.compound_forms << UMT::CompoundForm.new
    compound_form = UMT::CompoundForm.last
    compound_form.compound_form_contents << UMT::CompoundFormContent.new(:label_id => current_label.id)
    current_label.prepare_for_branching(@user.id)
    current_label.save!
    assert current_label.branched?
    current_label.prepare_for_merging
    assert_raise ActiveRecord::RecordInvalid do
      current_label.save_with_full_validation!
    end
  end

  def test_label_valid?
    current_label = Factory.create(:label)
    current_label.compound_forms << UMT::CompoundForm.new
    assert_equal false, current_label.valid_with_full_validation?
  end

  def test_has_concept_or_label_relations_should_return_false
    current_label = Factory.create(:label)
    assert_equal false, current_label.has_concept_or_label_relations? 
  end

  def test_has_concept_or_label_relations_should_return_true
    assert_equal true, @current_label.has_concept_or_label_relations? 
  end

  def test_should_create_change_note_after_branch
    label = Factory.build(:label_with_association)
    assert_equal @current_label.umt_change_notes.count, 0
    label.prepare_for_branching(@user.id)
    label.save!
    assert_equal label.umt_change_notes.count, 1
  end
  
  def test_should_generate_inflectionals
    label = Factory.create(:label_with_base_form)
    assert_equal label.inflectionals.count, 0
    label.generate_inflectionals!
    assert_equal label.inflectionals.count, 2
  end

end
