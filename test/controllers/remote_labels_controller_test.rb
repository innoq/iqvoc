# encoding: UTF-8

# Copyright 2011-2015 innoQ Deutschland GmbH
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

# test/models/dataset/iqvoc_dataset_test.rb
require 'test_helper'

class Dataset::IqvocDatasetTest < ActiveSupport::TestCase
  def setup
    @valid_url = 'http://localhost:3001'
    @concept_url = "#{@valid_url}/_05ec49ee"
    @original_load = RDF::Repository.method(:load)
  end

  def teardown
    RDF::Repository.define_singleton_method(:load, @original_load)
  end

  test "should initialize with available dataset" do
    RDF::Repository.define_singleton_method(:load) { |*args| RDF::Repository.new }

    dataset = Dataset::IqvocDataset.new(@valid_url)

    assert_equal URI.parse(@valid_url), dataset.url
    assert dataset.instance_variable_get(:@available)
    refute_nil dataset.instance_variable_get(:@repository)
  end

  test "should mark as unavailable on connection refused" do
    RDF::Repository.define_singleton_method(:load) { |*args| raise Errno::ECONNREFUSED.new('Connection refused') }

    dataset = Dataset::IqvocDataset.new(@valid_url)

    refute dataset.instance_variable_get(:@available)
    assert_nil dataset.instance_variable_get(:@repository)
  end

  test "should mark as unavailable on Faraday connection failed" do
    RDF::Repository.define_singleton_method(:load) { |*args| raise Faraday::ConnectionFailed.new('Connection refused') }

    dataset = Dataset::IqvocDataset.new(@valid_url)

    refute dataset.instance_variable_get(:@available)
    assert_nil dataset.instance_variable_get(:@repository)
  end

  test "should mark as unavailable on timeout" do
    RDF::Repository.define_singleton_method(:load) { |*args| raise Timeout::Error.new }

    dataset = Dataset::IqvocDataset.new(@valid_url)

    refute dataset.instance_variable_get(:@available)
    assert_nil dataset.instance_variable_get(:@repository)
  end

  test "should raise ServiceUnavailableError when finding label on unavailable dataset" do
    RDF::Repository.define_singleton_method(:load) { |*args| raise Errno::ECONNREFUSED.new('Connection refused') }

    dataset = Dataset::IqvocDataset.new(@valid_url)

    error = assert_raises(ServiceUnavailableError) do
      dataset.find_label(@concept_url)
    end

    assert_equal URI.parse(@valid_url), error.url
    assert_match(/Dataset unavailable/, error.message)
  end

  test "should use URL as name when repository unavailable" do
    RDF::Repository.define_singleton_method(:load) { |*args| raise Errno::ECONNREFUSED.new('Connection refused') }

    dataset = Dataset::IqvocDataset.new(@valid_url)

    assert_equal @valid_url, dataset.name
  end
end
