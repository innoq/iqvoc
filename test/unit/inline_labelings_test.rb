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

class InlineLabelingsTest < ActiveSupport::TestCase

  setup do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :foo rdf:type skos:Concept
      :foo skos:prefLabel "Foo"@en
      :foo skos:prefLabel "Fu"@de
    EOT
    @concept = Iqvoc::RDFAPI.cached(:foo)
    @inline_labelings = @concept.inline_labelings(:reload)
  end

  test 'inline_labelings should be hash of hashes' do
    assert @concept.inline_labelings.is_a?(Hash), "is a #{@concept.inline_labelings.class}"
    assert @concept.inline_labelings['skos:prefLabel'].is_a? Hash
    assert_equal 2, @concept.inline_labelings['skos:prefLabel'].keys.size
    assert @concept.inline_labelings['skos:altLabel'].is_a? Hash
    assert_equal 0, @concept.inline_labelings['skos:altLabel'].keys.size

    assert_equal 'Foo', @concept.inline_labelings['skos:prefLabel']['en']
  end

  test 'should accept inline labels' do
    @concept.inline_labelings = @inline_labelings.merge('skos:altLabel' => {'de' => 'Blah'})
    assert_equal 1, @concept.inline_labelings['skos:altLabel'].size
    assert_equal 0, @concept.labelings.for_rdf_class('skos:altLabel').size
    assert_equal 2, @concept.labelings.size
    assert @concept.valid?
    assert_equal 3, @concept.labelings.size
    assert_equal 1, @concept.labelings.for_rdf_class('skos:altLabel').size
  end

  test 'blank inline labels should be ignored' do
    @concept.inline_labelings = @inline_labelings.merge('skos:altLabel' => {'de' => ''})
    assert_equal 1, @concept.inline_labelings['skos:altLabel'].size
    @concept.valid?
    assert_equal 0, @concept.labelings.for_rdf_class('skos:altLabel').size
    assert_equal 2, @concept.labelings.size
  end

  test 'omitted inline notes should be destroyed' do
    @concept.inline_labelings = {'skos:prefLabel' => {}}
    assert_equal 2, @concept.labelings.size
    @concept.valid?
    assert_equal 0, @concept.labelings.size, @concept.labelings.inspect
  end

end
