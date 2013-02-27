# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'iqvoc/rdfapi'

API = Iqvoc::RDFAPI
class APITest < ActiveSupport::TestCase

  test 'should allow passing namespaced subject, predicate and object' do
    result = API.devour ':foobar', 'rdf:type', 'Concept::SKOS::Base'
    assert result.is_a? Concept::SKOS::Base
    assert_equal 'foobar', result.origin
  end

  test 'should interpret missing ":" as default namespace' do
    result = API.devour 'foobar', 'a', 'Concept::SKOS::Base'
    assert result.is_a? Concept::SKOS::Base
  end

  test 'should allow passing single string that will be interpreted' do
    result = API.devour 'foobar a Concept::SKOS::Base'
    assert result.is_a? Concept::SKOS::Base
  end

  test 'should instantiate known class names using strings only' do
    result = API.devour 'foobar', 'a', 'Concept::SKOS::Base'
    assert result.is_a? Concept::SKOS::Base
    assert_equal result.origin, 'foobar'
  end

  test 'should raise error when using string class name for nonexistent class' do
    assert_raise NameError do
      result = API.devour 'foobar', 'a', 'Concept::SKOS::Blah'
    end
  end

  test 'should instantiate known class names using constant' do
    result = API.devour 'foobar', 'a', Concept::SKOS::Base
    assert result.is_a? Concept::SKOS::Base
    assert_equal result.origin, 'foobar'
  end

  test 'should instantiate known class names from dictionary using strings only' do
    concept_result1 = API.devour 'foofoo', 'a', 'skos:Concept'
    assert concept_result1.is_a? Iqvoc::Concept.base_class

    concept_result2 = API.devour 'foobar', 'rdf:type', 'skos:Concept'
    assert concept_result2.is_a? Iqvoc::Concept.base_class

    collection_result = API.devour 'foobaz', 'a', 'skos:Collection'
    assert collection_result.is_a? Iqvoc::Collection.base_class
  end

  test 'should add member to collection using string predicate ' do
    foobar = API.devour 'foobar a skos:Concept'
    barbaz = API.devour 'barbaz a skos:Collection'
    member = API.devour barbaz, 'skos:member', foobar
    assert member.save
    assert member.is_a?(Collection::Member::SKOS::Base)
    assert_equal barbaz, member.collection
    assert_equal foobar, member.target
  end

  test 'should add member to collection using strings only' do
    API.devour('foobar-concept a skos:Concept').save
    API.devour('barbaz-collection a skos:Collection').save
    member = API.devour 'barbaz-collection skos:member foobar-concept'

    assert member.save
    assert member.is_a?(Collection::Member::SKOS::Base)
    assert_equal 'barbaz-collection', member.collection.origin
    assert_equal 'foobar-concept', member.target.origin
  end

  test 'should add member to collection using classes' do
    foobar = API.devour 'foobar a skos:Concept'
    barbaz = API.devour 'barbaz a skos:Collection'
    member = API.devour barbaz, Collection::Member::SKOS::Base, foobar

    assert member.save
    assert member.is_a?(Collection::Member::SKOS::Base)
    assert_equal barbaz, member.collection
    assert_equal foobar, member.target
  end

  test 'should add member to collection using multiline string' do
    API.parse_triples <<-EOS
      :foobar rdf:type skos:Concept
      :barbaz rdf:type skos:Collection
      :barbaz skos:member :foobar
    EOS

    assert Iqvoc::Concept.base_class.find_by_origin('foobar')
    assert Iqvoc::Collection.base_class.find_by_origin('barbaz')
  end

  test 'should set pref label using string' do
    foobar = API.devour *%w(foobar a skos:Concept)
    foobar.save
    labeling = API.devour foobar, 'skos:prefLabel', '"Foo Bar"@en'

    assert labeling.is_a? Labeling::SKOS::PrefLabel
    assert_equal 'en', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
    assert_equal 'Foo Bar', foobar.pref_labels.find_by_language('en').value
  end

  test 'should set pref label using multiline string' do
    API.parse_triples <<-EOS
      :foobar rdf:type skos:Concept
      :foobar skos:prefLabel "Foo Bar"@en
      :foobar skos:prefLabel "Föö Bär"@de
    EOS

    foobar = Concept::SKOS::Base.find_by_origin 'foobar'

    assert foobar.pref_labels
    assert_equal 'Foo Bar', foobar.pref_labels.find_by_language('en').value
    assert_equal 'Föö Bär', foobar.pref_labels.find_by_language('de').value
  end

  test 'should set pref label using class' do
    foobar   = API.devour ':foobar rdf:type skos:Concept'
    labeling = API.devour foobar, Labeling::SKOS::PrefLabel, '"Foo Bar"@en'

    assert labeling.is_a? Labeling::SKOS::PrefLabel
    assert_equal 'en', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
  end

  test 'should set alt label using string' do
    foobar   = API.devour ':foobar rdf:type skos:Concept'
    labeling = API.devour foobar, 'skos:altLabel', '"Foo Bar"@de'

    assert labeling.is_a? Labeling::SKOS::AltLabel
    assert_equal 'de', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
  end


end
