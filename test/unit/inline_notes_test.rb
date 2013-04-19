# encoding: UTF-8

# Copyright 2013 innoQ Deutschland GmbH
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

class InlineNotesTest < ActiveSupport::TestCase

  setup do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :foo rdf:type skos:Concept
      :foo skos:prefLabel "Foo"@en
      :foo skos:definition "Foo is foo."@en
      :foo skos:definition "Fu ist Fu."@de
      :foo skos:scopeNote "Foo is not bar."@en
      :foo skos:scopeNote "Foo ist nicht bar."@en
    EOT
    @concept = Iqvoc::RDFAPI.cached(:foo)
    @inline_notes = @concept.inline_notes(:reload)
  end

  test 'inline_notes should be hash of hashes' do
    assert @concept.inline_notes.is_a?(Hash), "is a #{@concept.inline_notes.class}"
    assert @concept.inline_notes['skos:definition'].is_a? Hash
    assert_equal 2, @concept.inline_notes['skos:definition'].keys.size
    assert @concept.inline_notes['skos:scopeNote'].is_a? Hash
    assert_equal 2, @concept.inline_notes['skos:scopeNote'].keys.size

    first_definition = @concept.notes.for_rdf_class('skos:definition').first
    assert_equal first_definition.value, @concept.inline_notes['skos:definition'][first_definition.id.to_s]['value']
  end

  test 'should accept inline notes' do
    @concept.inline_notes = @inline_notes.merge 'skos:historyNote' => {'123' => {:language => 'de', :value => 'trallalla'}}
    assert_equal 1, @concept.inline_notes['skos:historyNote'].size
    assert_equal 0, @concept.notes.for_rdf_class('skos:hostoryNote').size
    assert @concept.save
    assert_equal 1, @concept.notes.for_rdf_class('skos:historyNote').size
  end

  test 'blank inline notes should be ignored' do
    @concept.inline_notes = @inline_notes.merge 'skos:historyNote' => {'123' => {:language => 'de', :value => ''}}
    assert_equal 1, @concept.inline_notes['skos:historyNote'].size
    @concept.save
    assert_equal 0, @concept.reload.notes.for_rdf_class('skos:historyNote').size
    assert_equal 4, @concept.reload.notes.size
  end

  test 'inline notes marked for destruction should be destroyed' do
    first_definition = @concept.notes.for_rdf_class('skos:definition').first
    @inline_notes['skos:definition'][first_definition.id.to_s][:_destroy] = '1'
    @concept.inline_notes = @inline_notes
    assert_equal 2, @concept.inline_notes['skos:definition'].size, @concept.inline_notes['skos:definition'].inspect
    @concept.save
    assert_equal 1, @concept.reload.notes.for_rdf_class('skos:definition').size
  end

  test 'omitted inline notes should be destroyed' do
    @concept.inline_notes = {'skos:scopeNote' => {}, 'skos:definition' => {}}
    assert_equal 4, @concept.notes.size
    @concept.save
    assert_equal 0, @concept.reload.notes.size, @concept.notes.inspect
  end

end
