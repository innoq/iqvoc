# encoding: UTF-8

# Copyright 2011-2014 innoQ Deutschland GmbH
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

class ReverseMatchTest < ActionController::TestCase

  setup do
    @controller = ConceptsController.new

    Iqvoc.config.register_setting('sources.iqvoc', ['http://umthes.innoq.com'])

    @achievement_hobbies = Concept::SKOS::Base.new.tap do |c|
      Iqvoc::RDFAPI.devour c, 'skos:prefLabel', '"Achievement hobbies"@en'
      c.publish
      c.save
    end

    @request.env['HTTP_REFERER'] = 'http://iqvoc.net'
  end

  test 'match creation' do
    patch :add_match,
          lang: 'en',
          origin: @achievement_hobbies.origin,
          match_class: 'Match::SKOS::BroadMatch',
          uri: 'http://google.de'
    assert_response 200
  end
end
