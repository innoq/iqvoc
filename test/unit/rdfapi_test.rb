require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'iqvoc/rdfapi'

RDFAPI = Iqvoc::RDFAPI
class RDFAPITest < ActiveSupport::TestCase

  test 'should instantiate known class names using strings only' do
    result = RDFAPI.devour 'foobar', 'a', 'Concept::SKOS::Base'
    assert result.is_a? Concept::SKOS::Base
    assert_equal result.origin, 'foobar'
  end

  test 'should instantiate known class names using constant' do
    result = RDFAPI.devour 'foobar', 'a', Concept::SKOS::Base
    assert result.is_a? Concept::SKOS::Base
    assert_equal result.origin, 'foobar'
  end

  test 'should instantiate known class names from dictionary using strings only' do
    concept_result1 = RDFAPI.devour 'foofoo', 'a', 'skos:Concept'
    assert concept_result1.is_a? Iqvoc::Concept.base_class

    concept_result2 = RDFAPI.devour 'foobar', 'rdf:type', 'skos:Concept'
    assert concept_result2.is_a? Iqvoc::Concept.base_class

    collection_result = RDFAPI.devour 'foobaz', 'a', 'skos:Collection'
    assert collection_result.is_a? Iqvoc::Collection.base_class
  end

  test 'should add member to collection using strings only' do
    foobar = RDFAPI.devour *%w(foobar a skos:Concept)
    barbaz = RDFAPI.devour *%w(barbaz a skos:Collection)
    member = RDFAPI.devour barbaz, 'skos:member', foobar

    assert member.save
    assert member.is_a?(Collection::Member::SKOS::Base)
    assert_equal member.collection, barbaz
    assert_equal member.target, foobar
  end

  test 'should add member to collection using classes' do
    foobar = RDFAPI.devour *%w(foobar a skos:Concept)
    barbaz = RDFAPI.devour *%w(barbaz a skos:Collection)
    member = RDFAPI.devour barbaz, Collection::Member::SKOS::Base, foobar

    assert member.save
    assert member.is_a?(Collection::Member::SKOS::Base)
    assert_equal member.collection, barbaz
    assert_equal member.target, foobar
  end

  test 'should set pref label using string' do
    foobar = RDFAPI.devour *%w(foobar a skos:Concept)
    foobar.save
    labeling = RDFAPI.devour foobar, 'skos:prefLabel', '"Foo Bar"@en'

    assert labeling.is_a? Labeling::SKOS::PrefLabel
    assert_equal 'en', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
    assert_equal 'Foo Bar', foobar.pref_labels.find_by_language('en').value
  end

  test 'should set pref label using class' do
    foobar   = RDFAPI.devour *%w(foobar a skos:Concept)
    labeling = RDFAPI.devour foobar, Labeling::SKOS::PrefLabel, '"Foo Bar"@en'

    assert labeling.is_a? Labeling::SKOS::PrefLabel
    assert_equal 'en', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
  end

  test 'should set alt label using string' do
    foobar   = RDFAPI.devour *%w(foobar a skos:Concept)
    labeling = RDFAPI.devour foobar, 'skos:altLabel', '"Foo Bar"@de'

    assert labeling.is_a? Labeling::SKOS::AltLabel
    assert_equal 'de', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
  end
end
