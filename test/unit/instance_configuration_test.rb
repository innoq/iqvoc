require "test_helper"

class InstanceConfigurationTest < ActiveSupport::TestCase

  setup do
    @config = Iqvoc::InstanceConfiguration.instance
  end

  teardown do
    @config = nil
    # TODO: unset singleton?
  end

  test "should require a setting to be registered upfront" do
    assert_raise Iqvoc::InstanceConfiguration::UnregisteredSetting do
      @config["foo"] = "bar"
    end
  end

  test "should register settings with defaults" do
    @config.register_setting("ho", "yuken")
    assert_equal "yuken", @config["ho"]

    @config.register_settings("ha" => "douken")
    assert_equal "douken", @config["ha"]
  end

  test "should deregister settings" do
    @config.register_setting("country", "germany")
    assert_equal "germany", @config.deregister_setting("country")
    assert_nil @config["germany"]
  end

  test "should validate values" do
    @config.register_setting("foo", "bar")

    assert_raise(TypeError) { @config["foo"] = nil }
    assert_raise(TypeError) { @config.register_setting("foo", nil) }
    assert_raise(TypeError) { @config.register_setting("foo", Hash.new) }
  end

end
