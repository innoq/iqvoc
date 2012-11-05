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

require 'iqvoc/rdf_sync'

class RDFSyncTest < ActiveSupport::TestCase

  setup do
    @rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    @skos = "http://www.w3.org/2004/02/skos/core#"

    @base_url = "http://example.com/"
    @target_host = "http://example.org"
    @username = "johndoe"

    class FakeViewContext # XXX: does not belong here
      def iqvoc_default_rdf_namespaces
        return Iqvoc.rdf_namespaces
      end
    end
    @view_context = FakeViewContext.new

    @sync = Iqvoc::RDFSync.new(@base_url, @target_host, :username => @username,
        :view_context => @view_context)

    @concepts = 15.times.map do
      FactoryGirl.create(:concept, :narrower_relations => [])
    end

    # HTTP request mocking
    @observers = [] # one per request
    WebMock.disable_net_connect!
    WebMock.stub_request(:any, /.*example.org.*/).with do |req|
      # not using WebMock's custom assertions as those didn't seem to provide
      # sufficient flexibility
      fn = @observers.shift
      raise(TypeError, "missing request observer: #{req.inspect}") unless fn
      fn.call(req)
      true
    end.to_return do |req|
      { :status => 201 }
    end
  end

  teardown do
    WebMock.reset!
    WebMock.allow_net_connect!
    raise(TypeError, "unhandled request observer") unless @observers.length == 0
  end

  test "serialization" do
    concept = @concepts[0]

    assert @sync.serialize(concept).include?(<<-EOS.strip)
<#{@base_url}#{concept.origin}> <#{@rdf}type> <#{@skos}Concept> .
    EOS
  end

  test "single-batch syncronization" do
    concepts = @concepts[0..4]

    @observers << lambda do |req|
      concepts.each do |concept|
        uri = @base_url + concept.origin
        assert req.body.include?("CLEAR GRAPH <#{uri}>")
      end
    end
    @observers << lambda do |req|
      concepts.each do |concept|
        path = req.uri.path
        assert path.start_with?("/DAV/home/#{@username}/")
        assert_equal 4, path.count("/")
        uri = @base_url + concept.origin
        assert req.body.include?("INSERT IN GRAPH <#{uri}> {")
      end
    end
    res = @sync.sync(concepts)
  end

  test "full synchronization" do
    concepts = Iqvoc::Concept.base_class.published.unsynced

    assert_not_equal 0, concepts.count
    assert_not_equal 0, concepts.where(:rdf_updated_at => nil).count

    2.times do # 3 * 2 requests (reset + insert per batch)
      @observers << lambda { |req| } # no need to check details here
    end
    assert @sync.all
    assert_equal 0, concepts.where(:rdf_updated_at => nil).count
  end

  test "request batches" do
    concepts = Iqvoc::Concept.base_class.published.unsynced
    concept_count = concepts.count
    batch_count = 3

    sync = Iqvoc::RDFSync.new(@base_url, @target_host, :username => @username,
        :batch_size => (concept_count / batch_count).ceil,
        :view_context => @view_context)

    (batch_count * 2).times do # two requests (reset + insert) per batch
      @observers << lambda { |req| } # no need to check details here
    end
    assert sync.all
  end

end
