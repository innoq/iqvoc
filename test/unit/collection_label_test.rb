require 'test_helper'

class CollectionLabelTest < ActiveSupport::TestCase

  setup do
    @klass = Iqvoc::Collection.base_class
  end

  test "can have multiple labels" do
    myColl = @klass.new
    # add a few label[ing]s
    origin = 0
    Iqvoc::Concept.labeling_classes.each { |lnclass, langs|
      langs.each { |lang|
        origin += 1
        label = lnclass.label_class.new(:origin => "_%s" % origin,
            :value => "lipsum_%s" % origin, :language => lang)
        label.save
        labeling = lnclass.new(:owner => myColl, :target => label)
        labeling.save
      }
    }
    myColl.save

    assert myColl.labels.size > 1
    assert_equal myColl.labels.size, Iqvoc::Concept.labeling_classes.
        map { |lnclass, langs| langs }.flatten.size
  end

  test "must have a preferred label" do
    myColl = @klass.new

    # add an alternative label
    lnclass = Labeling::SKOSXL::AltLabel
    label = lnclass.label_class.new(:origin => "_666", :value => "lipsum",
        :language => "de")
    label.save
    labeling = lnclass.new(:owner => myColl, :target => label)
    labeling.save

    assert_raise ActiveRecord::RecordInvalid do
      myColl.save_with_full_validation!
    end
    assert_equal 1, myColl.labels.count

    # add a preferred label
    lnclass = Labeling::SKOSXL::PrefLabel
    label = lnclass.label_class.new(:origin => "_666", :value => "lipsum",
        :language => "de")
    label.save
    labeling = lnclass.new(:owner => myColl, :target => label)
    labeling.save

    assert_equal 2, myColl.labels.count
  end

  test "does not need more than one label" do
    myColl = @klass.new

    # add a preferred label
    lnclass = Labeling::SKOSXL::PrefLabel
    label = lnclass.label_class.new(:origin => "_666", :value => "lipsum",
        :language => "de")
    label.save
    labeling = lnclass.new(:owner => myColl, :target => label)
    labeling.save

    assert_equal true, myColl.save_with_full_validation!
    assert_equal 1, myColl.pref_labels.count
    assert_equal 1, myColl.labels.count
  end

  test "can have multiple preferred labels" do
    myColl = @klass.new

    # add multiple preferred labels
    lnclass = Labeling::SKOSXL::PrefLabel
    origin = 0
    5.times {
      origin += 1
      label = lnclass.label_class.new(:origin => "_%s" % origin,
          :value => "lipsum_%s" % origin, :language => "de")
      label.save
      labeling = lnclass.new(:owner => myColl, :target => label)
      labeling.save
    }

    assert_equal true, myColl.save_with_full_validation!
    assert_equal 5, myColl.pref_labels.count
    assert_equal 5, myColl.labels.count
  end
end
