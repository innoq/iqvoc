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
require 'iqvoc/rdfapi/canonical_triple_grammar'

class CanonicalTripleGrammarTest < ActiveSupport::TestCase
  include Iqvoc::RDFAPI::CanonicalTripleGrammar

  test 'should recognize absolute_uri' do
    assert r_absolute_uri.match('http://foobar')
    assert r_absolute_uri.match('http://foobar.com')
    assert r_absolute_uri.match('http://foobar.com/trallalla')
  end

  test 'should recognize namespaced_origin' do
    assert r_namespaced_origin.match(':bar')
    assert r_namespaced_origin.match('foo:bar')
    assert r_namespaced_origin.match('foo:_01231')
    assert !r_namespaced_origin.match('fooaslkdjasd')
    assert !r_namespaced_origin.match('fooa : slkdjasd')
  end

  test 'should recognize language' do
    assert r_language.match('ab')
    assert r_language.match('en3')
    assert r_language.match('de-DE')
    assert !r_language.match('0815')
  end

  test 'should recognize uriref' do
    assert r_uriref.match('<http://example.com>')
    assert r_uriref.match('<http://trallalla>')
    assert r_uriref.match('<http://example.com/tritratrullalla>')
    assert !r_uriref.match('http://example.com')
    assert !r_uriref.match('<http://example.com/tri tra trullalla>')
  end

  test 'should recognize datatype_string' do
    matchdata = r_datatype_string.match('"tadadaaa"^^<trallalla>')
    assert_equal 'tadadaaa', matchdata[:DatatypeString]
    assert_equal 'trallalla', matchdata[:DatatypeUri]
  end

  test 'should recognize lang_string' do
    assert r_lang_string.match('"tri træ trøllællæ"@no')
    matchdata = r_lang_string.match('"tri tra trallalla"@de')
    assert_equal 'tri tra trallalla', matchdata[:LangstringString]
    assert_equal 'de', matchdata[:LangstringLanguage]
  end

  test 'should recognize literal' do
    assert r_literal.match('"foo"@de')
    assert r_literal.match('"foo"^^<jo>')
  end

  test 'should recognize subject' do
    assert r_subject.match(':bar')
    assert r_subject.match('foo:bar')
  end

  test 'should recognize predicate' do
    matchdata = r_predicate.match(':baz')
    assert_not_nil matchdata
    assert_equal '', matchdata[:PredicatePrefix]
    assert_equal 'baz', matchdata[:PredicateOrigin]

    assert r_predicate.match('bar:baz')
    assert !r_predicate.match(':')
    assert !r_predicate.match('   ')
  end

  test 'should recognize object' do
    assert r_object.match(':bar')
    assert r_object.match('foo:bar')
    assert r_object.match('"foo"@de')
    assert r_object.match('"foo"@<http://trallalla>')
  end

  test 'should recognize triple' do
    matchdata = r_triple.match(':foo rdf:type skos:Concept')
    assert_not_nil matchdata
    assert_equal ':foo',         matchdata[:Subject]
    assert_equal 'rdf:type',     matchdata[:Predicate]
    assert_equal 'skos:Concept', matchdata[:Object]
  end

  test 'should recognize line' do
      matchdata = r_line.match('    :foo   rdf:type    skos:Concept  ')
    assert_equal ':foo   rdf:type    skos:Concept', matchdata[:Triple]
  end
end
