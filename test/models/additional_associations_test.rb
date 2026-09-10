require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class AdditionalAssociationsTest < ActiveSupport::TestCase
  Normalizer = Iqvoc::Configuration::AdditionalAssociations

  # Note::Annotated::Base belongs_to :note, so 'note_id' has a matching
  # association while 'owner_id' has not.
  ANNOTATION = 'Note::Annotated::Base'

  test 'a bare foreign key stays a valid registration' do
    options = Normalizer.normalize(ANNOTATION => 'note_id')

    assert_equal({ foreign_key: 'note_id', inverse_of: :note },
        options[Note::Annotated::Base])
  end

  test 'an explicit inverse is taken as given' do
    options = Normalizer.normalize(ANNOTATION => { foreign_key: 'note_id', inverse_of: :note })

    assert_equal :note, options[Note::Annotated::Base][:inverse_of]
  end

  test 'string keys are accepted' do
    options = Normalizer.normalize(ANNOTATION => { 'foreign_key' => 'note_id' })

    assert_equal 'note_id', options[Note::Annotated::Base][:foreign_key]
  end

  # a registration whose belongs_to is named differently must keep working,
  # even though it loses the inverse and with it the preloading benefit
  test 'a foreign key without matching association yields no inverse' do
    options = Normalizer.normalize(ANNOTATION => 'owner_id')

    assert_nil options[Note::Annotated::Base][:inverse_of]
  end

  test 'an explicit nil inverse is not second-guessed' do
    options = Normalizer.normalize(ANNOTATION => { foreign_key: 'note_id', inverse_of: nil })

    assert_nil options[Note::Annotated::Base][:inverse_of]
  end

  test 'preload spec names the association' do
    assert_equal [:note_annotated_bases],
        Normalizer.preload_spec(ANNOTATION => 'note_id')
  end

  test 'preload spec nests what a registration asks for' do
    spec = Normalizer.preload_spec(
        ANNOTATION => { foreign_key: 'note_id', preload: :note })

    assert_equal [{ note_annotated_bases: :note }], spec
  end

  test 'additional_association_classes still maps to the bare foreign key' do
    previous = Iqvoc::Concept.additional_association_class_names
    begin
      Iqvoc::Concept.additional_association_class_names =
          { ANNOTATION => { foreign_key: 'note_id', inverse_of: :note } }

      assert_equal({ Note::Annotated::Base => 'note_id' },
          Iqvoc::Concept.additional_association_classes)
    ensure
      Iqvoc::Concept.additional_association_class_names = previous
    end
  end
end
