require File.join(File.expand_path(File.dirname(__FILE__)), '../../test_helper')
require 'iqvoc/rdfapi'
require 'webmock/test_unit'

module SearchAdaptors
  class IqvocSearchAdaptorTest < ActiveSupport::TestCase
    RDFAPI = Iqvoc::RDFAPI

    setup do
      WebMock.disable_net_connect!
      stub_request(:get, /.*iqvoc.local\/search\.html/).
        to_return(:body => File.new(File.join(File.dirname(__FILE__), 'responses', 'foo.html')))

      @concept = RDFAPI.devour *%w(foobar a skos:Concept)
      @concept.publish
      @concept.save

      RDFAPI.devour @concept, 'skos:prefLabel', '"Foo Bar"@en'
    end

    test 'fetch remote search results' do
      remote = IqvocSearchAdaptor.new('http://one.iqvoc.local')
      results = remote.search(:q => 'a')

      assert results.respond_to?(:each)
      assert_equal 2, results.size

      results.each do |result|
        assert_kind_of SearchResult, result
      end
    end
  end
end
