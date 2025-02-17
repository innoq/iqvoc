require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class RDFAPITest < ActiveSupport::TestCase
  test 'should instantiate known class names using strings only' do
    result = RdfApi.devour 'foobar', 'a', 'Concept::Skos::Base'
    assert result.is_a? Concept::Skos::Base
    assert_equal result.origin, 'foobar'
  end

  test 'should instantiate known class names using constant' do
    result = RdfApi.devour 'foobar', 'a', Concept::Skos::Base
    assert result.is_a? Concept::Skos::Base
    assert_equal result.origin, 'foobar'
  end

  test 'should instantiate known class names from dictionary using strings only' do
    concept_result1 = RdfApi.devour 'foofoo', 'a', 'skos:Concept'
    assert concept_result1.is_a? Iqvoc::Concept.base_class

    concept_result2 = RdfApi.devour 'foobar', 'rdf:type', 'skos:Concept'
    assert concept_result2.is_a? Iqvoc::Concept.base_class

    collection_result = RdfApi.devour 'foobaz', 'a', 'skos:Collection'
    assert collection_result.is_a? Iqvoc::Collection.base_class
  end

  test 'should add member to collection using strings only' do
    foobar = RdfApi.devour *%w(foobar a skos:Concept)
    barbaz = RdfApi.devour *%w(barbaz a skos:Collection)
    member = RdfApi.devour barbaz, 'skos:member', foobar

    assert member.save
    assert member.is_a?(Collection::Member::Skos::Base)
    assert_equal member.collection, barbaz
    assert_equal member.target, foobar
  end

  test 'should add member to collection using classes' do
    foobar = RdfApi.devour *%w(foobar a skos:Concept)
    barbaz = RdfApi.devour *%w(barbaz a skos:Collection)
    member = RdfApi.devour barbaz, Collection::Member::Skos::Base, foobar

    assert member.save
    assert member.is_a?(Collection::Member::Skos::Base)
    assert_equal member.collection, barbaz
    assert_equal member.target, foobar
  end

  test 'should set pref label using string' do
    foobar = RdfApi.devour *%w(foobar a skos:Concept)
    foobar.save
    labeling = RdfApi.devour foobar, 'skos:prefLabel', '"Foo Bar"@en'

    assert labeling.is_a? Labeling::Skos::PrefLabel
    assert_equal 'en', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
    assert_equal 'Foo Bar', foobar.pref_labels.find_by_language('en').value
  end

  test 'should set pref label using class' do
    foobar   = RdfApi.devour *%w(foobar a skos:Concept)
    labeling = RdfApi.devour foobar, Labeling::Skos::PrefLabel, '"Foo Bar"@en'

    assert labeling.is_a? Labeling::Skos::PrefLabel
    assert_equal 'en', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
  end

  test 'should set alt label using string' do
    foobar   = RdfApi.devour *%w(foobar a skos:Concept)
    labeling = RdfApi.devour foobar, 'skos:altLabel', '"Foo Bar"@de'

    assert labeling.is_a? Labeling::Skos::AltLabel
    assert_equal 'de', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
  end
end
