# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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

class ConceptTest < ActiveSupport::TestCase
  test 'blank concept' do
    c = Concept::Base.new
    assert c.valid?
    refute c.publishable?
    assert c.valid?
  end

  test 'should not allow identical concepts' do
    origin = 'foo'
    c1 = Concept::Base.new(origin: origin)
    c2 = Concept::Base.new(origin: origin, published_at: Time.now)
    assert c1.save
    assert c2.save

    origin = 'bar'
    c1 = Concept::Base.new(origin: origin)
    c2 = Concept::Base.new(origin: origin)
    assert c1.save
    assert_raise ActiveRecord::RecordInvalid do
      c2.save!
    end
  end

  test 'concept with no preflabel' do
    concept = RDFAPI.devour 'bear', 'a', 'skos:Concept'

    assert concept.save
    refute concept.publishable?
    assert_raise ActiveRecord::RecordInvalid do
      concept.publish!
    end
  end

  test 'concepts without pref_labels should be saveable but not publishable' do
    concept =  RDFAPI.devour 'bear', 'a', 'skos:Concept'
    assert_equal [], concept.pref_labels
    assert concept.valid?
    refute concept.publishable?
  end

  test 'published concept must have a pref_label of the first pref_label language configured (the main language)' do
    concept = RDFAPI.devour 'bear', 'a', 'skos:Concept'
    RDFAPI.devour concept, 'skos:prefLabel', '"Bear"@en'

    assert concept.save

    assert_equal 1, concept.pref_labels.count

    assert concept.publishable?

    concept.pref_labels.first.language = Iqvoc::Concept.pref_labeling_languages.second
    assert !concept.publishable?
  end

  test 'one pref label per language' do
    concept = Concept::SKOS::Base.new.tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Bear"@en'
      c.publish
      c.save
    end

    assert concept.valid?
    RDFAPI.devour concept, 'skos:prefLabel', '"Beaaar"@en'
    concept.pref_labelings.reload
    assert_equal 2, concept.pref_labelings.count
    assert_equal concept.pref_labelings.first.target.language, concept.pref_labelings.second.target.language
    assert concept.invalid?
  end

  test 'unique pref label' do
    bear_one = RDFAPI.devour 'bear_one', 'a', 'skos:Concept'
    RDFAPI.devour bear_one, 'skos:prefLabel', '"Bear"@en'

    assert bear_one.save
    assert bear_one.publishable?

    bear_two = RDFAPI.devour 'bear_two', 'a', 'skos:Concept'
    RDFAPI.devour bear_two, 'skos:prefLabel', '"Bear"@en'

    bear_two.save!
    refute bear_two.publishable?
  end

  test 'unique alt labels' do
    tiger = RDFAPI.devour 'tiger', 'a', 'skos:Concept'
    RDFAPI.devour tiger, 'skos:prefLabel', '"Tiger"@en'

    assert tiger.save
    assert tiger.publishable?

    # two identical alt labels
    RDFAPI.devour tiger, 'skos:altLabel', '"Big cat"@en'
    RDFAPI.devour tiger, 'skos:altLabel', '"Big cat"@en'

    tiger.save!
    tiger.reload
    refute tiger.publishable?, 'There should be no identical alt labels'
  end

  test 'distinct labels' do
    monkey = RDFAPI.devour 'Monkey', 'a', 'skos:Concept'
    RDFAPI.devour monkey, 'skos:prefLabel', '"Monkey"@en'

    assert monkey.save
    assert monkey.publishable?

    # identical to pref label
    RDFAPI.devour monkey, 'skos:altLabel', '"Monkey"@en'

    monkey.save!
    monkey.reload
    refute monkey.publishable?, 'There should be no duplicates between prefLabel/altLabel'
  end

  test 'multiple pref labels' do
    concept = RDFAPI.devour 'bear', 'a', 'skos:Concept'
    RDFAPI.devour concept, 'skos:prefLabel', '"Bear"@en'
    RDFAPI.devour concept, 'skos:prefLabel', '"Bär"@de'

    assert concept.save
    concept.reload

    assert_equal 2, concept.pref_labels.count
    assert_not_equal concept.pref_labels.first.language, concept.pref_labels.second.language
    assert concept.publishable?
  end

  test 'labelings_by_text setter' do
    concept = Concept::SKOS::Base.new

    concept.labelings_by_text = {
      Iqvoc::Concept.pref_labeling_class_name.to_relation_name => {
        Iqvoc::Concept.pref_labeling_languages.first => 'A new label'
      }
    }

    assert concept.valid?
    assert concept.save
    concept.reload
    assert_equal 'A new label', concept.pref_label.value
    assert_equal Iqvoc::Concept.pref_labeling_languages.first, concept.pref_label.language.to_s

    concept.labelings_by_text = {
      Iqvoc::Concept.pref_labeling_class_name.to_relation_name => {
        Iqvoc::Concept.pref_labeling_languages.first => 'A new label, Another Label in the same language'
      }
    }
    refute concept.save
  end

  test 'labels including commas' do
    labels_for = lambda do |concept, type|
        type.includes(:target).where(owner_id: concept.id).
            map { |ln| ln.target.value }
    end

    form_data = {
      'labelings_by_text' => {
        'labeling_skos_pref_labels' => { 'en' => 'lipsum' },
        'labeling_skos_alt_labels' => { 'en' => 'foo, bar' }
      }
    }
    concept = Iqvoc::Concept.base_class.create(form_data)

    assert_equal ['lipsum'], labels_for.call(concept, Labeling::SKOS::PrefLabel)
    assert_equal 'lipsum',
        concept.labelings_by_text('labeling_skos_pref_labels', 'en')
    assert_equal ['foo', 'bar'],
        labels_for.call(concept, Labeling::SKOS::AltLabel)
    assert_equal 'foo, bar',
        concept.labelings_by_text('labeling_skos_alt_labels', 'en')

    form_data = {
      'labelings_by_text' => {
        'labeling_skos_pref_labels' => { 'en' => 'lipsum' },
        'labeling_skos_alt_labels' => { 'en' => 'lorem, "foo, bar", ipsum' }
      }
    }
    concept = Iqvoc::Concept.base_class.create(form_data)

    assert_equal ['lipsum'], labels_for.call(concept, Labeling::SKOS::PrefLabel)
    assert_equal 'lipsum',
        concept.labelings_by_text('labeling_skos_pref_labels', 'en')
    assert_equal ['lorem', 'foo, bar', 'ipsum'],
        labels_for.call(concept, Labeling::SKOS::AltLabel)
    assert_equal 'lorem, "foo, bar", ipsum',
        concept.labelings_by_text('labeling_skos_alt_labels', 'en')
  end
end
