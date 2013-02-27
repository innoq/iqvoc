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
require 'iqvoc/rdfapi/nt_parser'

class NTParserTest < ActiveSupport::TestCase

  test 'should parse W3C test cases without error' do
    test_triples = File.open('test/test.nt')
    parser = Iqvoc::RDFAPI::NTParser.new(test_triples, 'http://example.org/')
    parser.each_valid_line do |matchdata|
      assert matchdata
    end
  end

  test 'should '

end
