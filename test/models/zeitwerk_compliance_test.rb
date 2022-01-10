require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager loads all files without errors" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
