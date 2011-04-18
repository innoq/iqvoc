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

require 'test_helper'

class CollectionLabelTest < ActiveSupport::TestCase

  test "can have multiple labels" do
    my_coll = Factory.build(:collection)
    # add a few label[ing]s
    origin = 0
    Iqvoc::Concept.labeling_classes.each { |lnclass, langs|
      langs.each { |lang|
        origin += 1
        label = lnclass.label_class.new(:origin => "_#{origin}",
            :value => "lipsum_#{origin}", :language => lang)
        label.save
        labeling = lnclass.new(:owner => my_coll, :target => label)
        labeling.save
      }
    }
    my_coll.save

    assert my_coll.labels.count > 1
    assert_equal my_coll.labels.count, Iqvoc::Concept.labeling_classes.
        map { |lnclass, langs| langs }.flatten.size
  end

  test "must have a preferred label" do
    my_coll = Factory.build(:collection)

    # add an alternative label
    lnclass = Labeling::SKOSXL::AltLabel
    label = lnclass.label_class.new(:origin => "_666", :value => "lipsum",
        :language => "de")
    label.save
    labeling = lnclass.new(:owner => my_coll, :target => label)
    labeling.save

    assert_raise ActiveRecord::RecordInvalid do
      my_coll.save_with_full_validation!
    end
    assert_equal 1, my_coll.labels.count

    # add a preferred label
    lnclass = Labeling::SKOSXL::PrefLabel
    label = lnclass.label_class.new(:origin => "_666", :value => "lipsum",
        :language => "de")
    label.save
    labeling = lnclass.new(:owner => my_coll, :target => label)
    labeling.save

    assert_equal 2, my_coll.labels.count
  end

  test "does not need more than one label" do
    my_coll = Factory.build(:collection)

    # add a preferred label
    lnclass = Labeling::SKOSXL::PrefLabel
    label = lnclass.label_class.new(:origin => "_666", :value => "lipsum",
        :language => "de")
    label.save
    labeling = lnclass.new(:owner => my_coll, :target => label)
    labeling.save

    assert_equal true, my_coll.save_with_full_validation!
    assert_equal 1, my_coll.pref_labels.count
    assert_equal 1, my_coll.labels.count
  end

  test "can have multiple preferred labels" do
    my_coll = Factory.build(:collection)

    # add multiple preferred labels
    lnclass = Labeling::SKOSXL::PrefLabel
    origin = 0
    5.times {
      origin += 1
      label = lnclass.label_class.new(:origin => "_#{origin}",
          :value => "lipsum_#{origin}", :language => "de")
      label.save
      labeling = lnclass.new(:owner => my_coll, :target => label)
      labeling.save
    }

    assert_equal true, my_coll.save_with_full_validation!
    assert_equal 5, my_coll.pref_labels.count
    assert_equal 5, my_coll.labels.count
  end
end
