# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

require 'iqvoc/adaptors/sparql'

class SparqlAdaptorTest < ActiveSupport::TestCase
  
  setup do
    @adaptor = Iqvoc::Adaptors::Sparql.new("http://cr.eionet.europa.eu/sparql")
  end
  
  test "simple query" do
    response = @adaptor.query("?person a foaf:Person. ?person foaf:mbox ?email.",
      :prefixes => { :foaf => "http://xmlns.com/foaf/0.1/" })
    
    # default is JSON
    assert_equal Hash, response.class
  end
  
end
