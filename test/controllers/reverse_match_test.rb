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
    @controller = ReverseMatchesController.new

    @admin = User.create! do |u|
      u.forename = 'Test'
      u.surname = 'User'
      u.email = 'admin@iqvoc'
      u.password = 'omgomgomg'
      u.password_confirmation = 'omgomgomg'
      u.role = 'administrator'
      u.active = true
    end

    Iqvoc.config['sources.iqvoc'] = ['http://try.iqvoc.net']

    @achievement_hobbies = Concept::Skos::Base.new.tap do |c|
      RdfApi.devour c, 'skos:prefLabel', '"Achievement hobbies"@en'
      c.publish
      c.save
    end

    @airsoft = Concept::Skos::Base.new.tap do |c|
      RdfApi.devour c, 'skos:prefLabel', '"Airsoft"@en'
      c.publish
      c.save
      new_version = c.branch
      new_version.save
    end

    @request.env['HTTP_ACCEPT'] = 'application/json'
    @request.env['HTTP_REFERER'] = 'http://try.iqvoc.net'
  end

  teardown do
    Iqvoc.config['sources.iqvoc'] = []
  end

  test 'remove non existing match' do
    m = Match::Skos::NarrowMatch.create concept_id: @achievement_hobbies.id, value: 'http://iqvoc.net'
    patch :remove_match, params: {
      origin: @achievement_hobbies.origin,
      match_class: 'match_skos_relatedmatch',
      uri: 'http://iqvoc.net'
    }
    assert_response 400
    body = JSON.parse response.body
    assert_equal body['type'], "unknown_relation"
  end

  test 'remove match' do
    m = Match::Skos::NarrowMatch.create concept_id: @achievement_hobbies.id, value: 'http://iqvoc.net'
    patch :remove_match, params: {
      origin: @achievement_hobbies.origin,
      match_class: 'match_skos_broadmatch',
      uri: 'http://iqvoc.net'
    }
    assert_response 200
    body = JSON.parse response.body
    assert_equal body['type'], 'mapping_removed'

    new_concept_version = Iqvoc::Concept.base_class.by_origin(@achievement_hobbies.origin).last
    assert_equal 2, new_concept_version.rev
  end

  test 'add match' do
    patch :add_match, params: {
      origin: @achievement_hobbies.origin,
      match_class: 'match_skos_broadmatch',
      uri: 'http://google.de'
    }
    assert_response 200
    body = JSON.parse response.body
    assert_equal body['type'], 'mapping_added'

    new_concept_version = Iqvoc::Concept.base_class.by_origin(@achievement_hobbies.origin).last
    assert_equal 2, new_concept_version.rev
  end

  test 'add already existing match' do
    patch :add_match, params: {
      origin: @achievement_hobbies.origin,
      match_class: 'match_skos_broadmatch',
      uri: 'http://google.de'
    }
    assert_response 200
    body = JSON.parse response.body
    assert_equal body['type'], 'mapping_added'

    new_concept_version = Iqvoc::Concept.base_class.by_origin(@achievement_hobbies.origin).last
    assert_equal 2, new_concept_version.rev

    patch :add_match, params: {
      origin: @achievement_hobbies.origin,
      match_class: 'match_skos_broadmatch',
      uri: 'http://google.de'
    }
    assert_response 409
    body = JSON.parse response.body
    assert_equal body['type'], 'mapping_exists'

    new_concept_version = Iqvoc::Concept.base_class.by_origin(@achievement_hobbies.origin).last
    assert_equal 2, new_concept_version.rev
  end


  test 'no referer' do
    @request.env['HTTP_REFERER'] = nil
    patch :add_match, params: {
      origin: @achievement_hobbies.origin,
      match_class: 'match_skos_broadmatch',
      uri: 'http://google.de'
    }
    assert_response 400
    body = JSON.parse response.body
    assert_equal body['type'], "no_referer"
  end

  test 'unknown match class' do
    patch :add_match, params: {
      origin: @achievement_hobbies.origin,
      match_class: 'UnknownMatch',
      uri: 'http://google.de'
    }
    assert_response 400
    body = JSON.parse response.body
    assert_equal body['type'], "unknown_match"
  end

  test 'unknown referer' do
    @request.env['HTTP_REFERER'] = 'http://iqvoc.net'
    patch :add_match, params: {
      origin: @achievement_hobbies.origin,
      match_class: 'match_skos_broadmatch',
      uri: 'http://iqvoc.net'
    }
    assert_response 403
    body = JSON.parse response.body
    assert_equal body['type'], "unknown_referer"
  end

  test 'concept with a version' do
    patch :add_match, params: {
      origin: @airsoft.origin,
      match_class: 'match_skos_broadmatch',
      uri: 'http://iqvoc.net'
    }
    assert_response 403
    body = JSON.parse response.body
    assert_equal body['type'], "in_processing"
  end

  test 'missing parameter' do
    patch :add_match, params: {
      origin: @achievement_hobbies.origin,
      uri: 'http://google.de'
    }
    assert_response 400
    body = JSON.parse response.body
    assert_equal body['type'], "parameter_missing"
  end
end
