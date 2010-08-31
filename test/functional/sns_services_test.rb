require File.dirname(__FILE__) + '/../test_helper'
require 'net/http'
require 'sns_services_controller'

class SnsServicesController; def rescue_action(e) raise e end; end

class SnsServicesControllerTest < ActionController::TestCase
  
  setup :set_accept_header_xml

  def test_should_get_usage_for_empty_parameter
    get :get_synonyms
    assert_response(200)
    
    body = REXML::Document.new(@response.body) 
    message = REXML::XPath.match( body, "/iqvoc/message/text()" ) 
    # assert_equal("not a valid term. Parameter needs to be: term[]=...", message[0].to_s.strip)
    assert_equal("", message[0].to_s.strip)
  end
  
  def test_should_get_get_usage_for_wrong_parametername
    get (:get_synonyms,{"wrongparam" => "wrong"} )
    assert_response(200)

    body = REXML::Document.new(@response.body) 
    message = REXML::XPath.match( body, "/iqvoc/message/text()" ) 
    # assert_equal("not a valid term. Parameter needs to be: term[]=...", message[0].to_s.strip)
    assert_equal("", message[0].to_s.strip)
  end
  
  def test_should_return_something
    server_host = "79.125.17.123"
    server_port = ""

    Net::HTTP.start(server_host) do |http|
      req = Net::HTTP::Get.new('/sns_services/get_synonyms?term=Wales')
      response = http.request(req)
      assert_equal(response.code, "200")
      body = REXML::Document.new(response.body) 
      
    end
  end
  
  private
  def set_accept_header_xml
    @request.accept = 'text/xml'
  end
end