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
require 'webmock/minitest'

class ReverseMatchJobTest < ActiveSupport::TestCase
  include ReverseMatchErrors

  setup do
    @achievement_hobbies = Concept::SKOS::Base.new.tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Achievement hobbies"@en'
      c.publish
      c.save
    end

    @airsoft = Concept::SKOS::Base.new(origin: 'airsoft').tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Airsoft"@en'
      c.publish
      c.save
    end

    @reverse_match_service = Services::ReverseMatchService.new('http://try.iqvoc.com', 80)

    body = {links: [
      { rel: 'self', href: 'http://0.0.0.0:3000/en/concepts/airsoft', method: 'get' },
      { rel: 'add_match',href: 'http://0.0.0.0:3000/airsoft/add_match', method: 'patch' },
      { rel: 'remove_match', href: 'http://0.0.0.0:3000/airsoft/remove_match', method: 'patch' }
    ]}.to_json

    stub_request(:get, 'http://try.iqvoc.com/')
      .with(:headers => {'Accept' => 'application/json', 'User-Agent' => 'Faraday v0.9.0'})
      .to_return(status: 200, body: body, headers: {})

    @worker = Delayed::Worker.new
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end

  test 'successfull job' do
    status, body = status_and_body(:mapping_added)
    stub_request(:patch, 'http://0.0.0.0:3000/airsoft/add_match?match_class=match_skos_broadmatch&uri=http://try.iqvoc.com/airsoft')
      .with(:headers => {'Accept' => '*/*', 'Content-Type'=>'application/json', 'Referer'=>'http://try.iqvoc.com/', 'User-Agent'=>'Faraday v0.9.0'})
      .to_return(status: status, body: body.to_json, headers: {})

    job = @reverse_match_service.build_job(:add_match, @airsoft, 'http://try.iqvoc.com', 'Match::SKOS::BroadMatch')
    @reverse_match_service.add(job)

    job = Delayed::Job.last
    @worker.run(job)

    assert_equal 0, @airsoft.job_relations.size
  end

  test 'job timeout' do
    status, body = status_and_body(:mapping_added)
    stub_request(:patch, 'http://0.0.0.0:3000/airsoft/add_match?match_class=match_skos_broadmatch&uri=http://try.iqvoc.com/airsoft').to_timeout

    job = @reverse_match_service.build_job(:add_match, @airsoft, 'http://try.iqvoc.com', 'Match::SKOS::BroadMatch')
    @reverse_match_service.add(job)

    job = Delayed::Job.last
    @worker.run(job)

    assert_equal 1, @airsoft.job_relations.size

    job_relation = @airsoft.job_relations.first
    assert_equal 'timeout_error', job_relation.response_error
  end

  test 'unknown resource' do
    status, body = status_and_body(:mapping_added)
    stub_request(:patch, 'http://0.0.0.0:3000/airsoft/add_match?match_class=match_skos_broadmatch&uri=http://try.iqvoc.com/airsoft').to_return(status: 404)

    job = @reverse_match_service.build_job(:add_match, @airsoft, 'http://try.iqvoc.com', 'Match::SKOS::BroadMatch')
    @reverse_match_service.add(job)

    job = Delayed::Job.last
    @worker.run(job)

    assert_equal 1, @airsoft.job_relations.size

    job_relation = @airsoft.job_relations.first
    assert_equal 'resource_not_found', job_relation.response_error
  end

  test 'unknown match class' do
    status, body = status_and_body(:unknown_match)
    stub_request(:patch, 'http://0.0.0.0:3000/airsoft/add_match?match_class=match_skos_broadmatch&uri=http://try.iqvoc.com/airsoft')
      .with(:headers => {'Accept' => '*/*', 'Content-Type'=>'application/json', 'Referer'=>'http://try.iqvoc.com/', 'User-Agent'=>'Faraday v0.9.0'})
      .to_return(status: status, body: body.to_json, headers: {})

    job = @reverse_match_service.build_job(:add_match, @airsoft, 'http://try.iqvoc.com', 'Match::SKOS::BroadMatch')
    @reverse_match_service.add(job)

    job = Delayed::Job.last
    @worker.run(job)

    assert_equal 1, @airsoft.job_relations.size

    job_relation = @airsoft.job_relations.first
    assert_equal 'unknown_match', job_relation.response_error
  end
end
