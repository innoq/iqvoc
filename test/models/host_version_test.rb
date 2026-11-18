# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class HostVersionTest < ActiveSupport::TestCase
  setup do
    @host_namespace = Iqvoc.host_namespace
  end

  teardown do
    Iqvoc.host_namespace = @host_namespace
  end

  test 'host_version is nil without a host namespace' do
    Iqvoc.host_namespace = nil

    assert_nil Iqvoc.host_version
  end

  test 'host_version is the VERSION of the host namespace' do
    Iqvoc.host_namespace = Module.new.tap { |m| m.const_set(:VERSION, '1.2.3') }

    assert_equal '1.2.3', Iqvoc.host_version
  end

  test 'host_version is nil if the host namespace has no VERSION' do
    Iqvoc.host_namespace = Module.new

    assert_nil Iqvoc.host_version
  end
end
