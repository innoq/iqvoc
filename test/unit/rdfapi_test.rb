# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'iqvoc/rdfapi'

API = Iqvoc::RDFAPI
class RDFAPITest < ActiveSupport::TestCase

  test 'should allow passing namespaced subject, predicate and object' do
    result = API.parse_triple(':foobar rdf:type skos:Concept')
    assert result.is_a? Concept::SKOS::Base
    assert_equal 'foobar', result.origin
  end

  test 'should instantiate known class names from dictionary using strings only' do
    concept_result1 = API.parse_triple(':foofoo rdf:type skos:Concept')
    assert concept_result1.is_a? Iqvoc::Concept.base_class

    collection_result = API.parse_triple(':foobaz rdf:type skos:Collection')
    assert collection_result.is_a? Iqvoc::Collection.base_class
  end

  test 'should add member to collection using strings only' do
    collection_origin = "_#{rand 10000}"
    concept_origin    = "_#{rand 10000}"

    API.parse_triple(%Q(:#{concept_origin} rdf:type skos:Concept)).save
    API.parse_triple(%Q(:#{collection_origin} rdf:type skos:Collection)).save
    member = API.parse_triple(%Q(:#{collection_origin} skos:member :#{concept_origin}))

    assert member.save
    assert member.is_a?(Collection::Member::SKOS::Base)
    assert_equal collection_origin, member.collection.origin
    assert_equal concept_origin, member.target.origin
  end

  test 'should cache created concepts' do
    assert_nil API.cached('monkey')
    assert_nil API.cached('nietzsche')

    API.parse_triple(':monkey rdf:type skos:Concept')
    assert_not_nil API.cached('monkey')
    API.parse_triple(':nietzsche rdf:type skos:Concept')
    assert_not_nil API.cached('monkey')
    assert_not_nil API.cached('nietzsche')
  end

  test 'should add member to collection using multiline string' do
    collection_origin = "_#{rand 10000}"
    concept_origin    = "_#{rand 10000}"
    API.parse_triples <<-EOS
      :#{concept_origin} rdf:type skos:Concept
      :#{collection_origin} rdf:type skos:Collection
      :#{collection_origin} skos:member :#{concept_origin}
    EOS

    assert Iqvoc::Concept.base_class.find_by_origin(concept_origin)
    coll = Iqvoc::Collection.base_class.find_by_origin(collection_origin)
    assert coll
  end

  test 'should set pref label using string' do
    foobar = API.parse_triple(':foobar rdf:type skos:Concept')
    foobar.save
    labeling = API.parse_triple(':foobar skos:prefLabel "Foo Bar"@en')

    assert labeling.is_a? Labeling::SKOS::PrefLabel
    assert_equal 'en', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.save
    assert_equal 'Foo Bar', foobar.pref_labels.find{|l| l.language == 'en'}.value
  end

  test 'should set pref label using multiline string' do
    origin = "_#{rand 10000}"
    API.parse_triples <<-EOS
      :#{origin} rdf:type skos:Concept
      :#{origin} skos:prefLabel "Foo Bar"@en
      :#{origin} skos:prefLabel "Föö Bär"@de
    EOS

    concept = Iqvoc::Concept.base_class.find_by_origin origin
    assert_not_nil API.cached(origin)
    assert_not_nil concept

    assert concept.pref_labels
    assert_equal 'Foo Bar', concept.pref_labels.find{|l| l.language == 'en'}.value
    assert_equal 'Föö Bär', concept.pref_labels.find{|l| l.language == 'de'}.value
  end

  test 'should set alt label using string' do
    foobar   = API.parse_triple(':_foobar0123 rdf:type skos:Concept')
    labeling = API.parse_triple(':_foobar0123 skos:altLabel "Foo Bar"@de')

    assert labeling.is_a? Labeling::SKOS::AltLabel
    assert_equal 'de', labeling.target.language
    assert_equal 'Foo Bar', labeling.target.value
    assert labeling.new_record?
    assert_equal labeling.object_id, foobar.labelings.first.object_id
    assert foobar.save
    assert_equal 'Foo Bar', foobar.reload.labelings.for_rdf_class('skos:altLabel').first.target.value
  end

  test 'should allow publishing a concept' do
    origin = "_#{rand 10000}"
    API.parse_triples <<-EOS
      :#{origin} rdf:type skos:Concept
      :#{origin} skos:prefLabel "Foo Bar"@en
    EOS
    assert !API.cached(origin).published?

    API.parse_triple %Q(:#{origin} iqvoc:publishedAt "#{3.days.ago}"^^<DateTime>)
    assert API.cached(origin).published?
  end
end
