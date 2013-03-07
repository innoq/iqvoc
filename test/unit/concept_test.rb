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

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'iqvoc/rdfapi'

class ConceptTest < ActiveSupport::TestCase

  test 'should not allow identical concepts' do
    origin = 'foo'
    c1 = Concept::Base.new(:origin => origin)
    c2 = Concept::Base.new(:origin => origin, :published_at => Time.now)
    assert c1.save
    assert c2.save

    origin = 'bar'
    c1 = Concept::Base.new(:origin => origin)
    c2 = Concept::Base.new(:origin => origin)
    assert c1.save
    assert_raise ActiveRecord::RecordInvalid do
      c2.save!
    end
  end

  test 'should not save concept with empty preflabel' do
    assert_raise ActiveRecord::RecordInvalid do
      concept = Concept::Base.create(:origin => 'c0819')
      concept.save_with_full_validation!
    end

    concept = Concept::Base.new(:origin => 'c0820')
    Iqvoc::RDFAPI.parse_triple ':c0820 skos:prefLabel "something"@en'
    concept.save_with_full_validation!
  end

  test 'concepts without pref_labels should be saveable but not publishable' do
    concept = Iqvoc::RDFAPI.parse_triple ':c0818 rdf:type skos:Concept'
    concept.save
    assert_equal [], concept.pref_labels
    assert concept.valid?
    assert !concept.valid_with_full_validation?
  end

  test 'published concept must have a pref_label of the first pref_label language configured (the main language)' do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :c0820 rdf:type skos:Concept
      :c0820 skos:prefLabel "foo-en"@en
    EOT
    concept = Iqvoc::RDFAPI.cached('c0820').reload
    assert_equal 1, concept.pref_labels.count
    assert concept.valid_with_full_validation?

    concept.pref_labels.first.language = Iqvoc::Concept.pref_labeling_languages.second
    assert !concept.valid_with_full_validation?
  end

  test 'concept shouldn not have more than one pref label of the same language' do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :c0817 rdf:type skos:Concept
      :c0817 skos:prefLabel "foo-en"@en
      :c0817 skos:prefLabel "foo-en the second"@en
    EOT
    concept = Iqvoc::RDFAPI.cached('c0817')
    concept.reload
    assert_equal 2, concept.pref_labelings.count
    assert_equal concept.pref_labelings.first.target.language, concept.pref_labelings.second.target.language
    assert concept.invalid?
  end

  test 'concepts can have multiple preferred labels in different languages' do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :c0816 rdf:type skos:Concept
      :c0816 skos:prefLabel "foo-en"@en
      :c0816 skos:prefLabel "foo-de"@de
    EOT
    concept  = Iqvoc::RDFAPI.cached('c0816')
    assert concept.invalid_with_full_validation?
  end

  test 'unique pref label' do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :c0818 rdf:type skos:Concept
      :c0818 skos:prefLabel "c0818"@en
    EOT
    concept1 = Iqvoc::RDFAPI.cached('c0818')
    assert concept1.valid_with_full_validation?

    Iqvoc::RDFAPI.parse_triples <<-EOT
      :c0819 rdf:type skos:Concept
      :c0819 skos:prefLabel "c0819"@en
    EOT
    concept2 = Iqvoc::RDFAPI.cached('c0819')
    assert concept2.invalid_with_full_validation?, "concept invalid: #{concept2.errors.full_messages.join(', ')}"
  end

  test 'labelings_by_text setter' do
    concept = Iqvoc::RDFAPI.parse_triple ':c0899 rdf:type skos:Concept'

    concept.labelings_by_text = {
      Iqvoc::Concept.pref_labeling_class.rdf_internal_name => {Iqvoc::Concept.pref_labeling_languages.first => 'A new label'}
    }
    assert concept.save
    concept.reload
    assert_equal 'A new label', concept.pref_label.value
    assert_equal Iqvoc::Concept.pref_labeling_languages.first, concept.pref_label.language.to_s

    concept.labelings_by_text = {
      Iqvoc::Concept.pref_labeling_class.rdf_internal_name => {Iqvoc::Concept.pref_labeling_languages.first => 'A new label, Another Label in the same language'}
    }
    assert !concept.save
  end

  test 'assigning labeling subtypes' do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :c0815 rdf:type skos:Concept
      :c0815 skos:prefLabel "foo-en"@en
      :c0815 skos:prefLabel "foo-de"@de
      :c0815 skos:altLabel "foo-bar"@en
      :c0815 skos:altLabel "foo-baz"@en
    EOT
    concept = Iqvoc::RDFAPI.cached('c0815')

    assert_equal 4, concept.labelings.count
    assert_equal 2, concept.labelings.skos_pref_label.size
    assert_equal 2, concept.labelings.skos_alt_label.size
  end

  test 'labels including commas' do
    form_data = {
      'labelings_by_text' => {
        'skos:prefLabel' => { 'en' => 'lipsum' },
        'skos:altLabel'  => { 'en' => 'foo, bar' }
      }
    }
    concept = Iqvoc::Concept.base_class.create(form_data)
    assert_equal ['lipsum'],
        concept.labelings.for_class(Labeling::SKOS::PrefLabel).map(&:target).map(&:to_s)
    assert_equal 'lipsum',
        concept.labelings_by_text('skos:prefLabel', 'en')
    assert_equal ['foo', 'bar'],
        concept.labelings.for_class(Labeling::SKOS::AltLabel).map(&:target).map(&:to_s)
    assert_equal 'foo, bar',
        concept.labelings_by_text('skos:altLabel', 'en')

    form_data = {
      'labelings_by_text' => {
        'skos:prefLabel' => { 'en' => 'lipsum' },
        'skos:altLabel'  => { 'en' => 'lorem, "foo, bar", ipsum' }
      }
    }
    concept = Iqvoc::Concept.base_class.create(form_data)

    assert_equal ['lipsum'],
        concept.labelings.for_class(Labeling::SKOS::PrefLabel).map(&:target).map(&:to_s)
    assert_equal 'lipsum',
        concept.labelings_by_text('skos:prefLabel', 'en')
    assert_equal ['lorem', 'foo, bar', 'ipsum'],
        concept.labelings.for_class(Labeling::SKOS::AltLabel).map(&:target).map(&:to_s)
    assert_equal 'lorem, "foo, bar", ipsum',
        concept.labelings_by_text('skos:altLabel', 'en')
  end

end
