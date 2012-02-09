# encoding: UTF-8

class HygieneTest < ActiveSupport::TestCase

  test "trailing whitespace" do
    assert_no_occurrence '[[:blank:]]$', "trailing whitespace"
  end

  test "mixed whitespace" do
    tab = "	"
    space = " "
    assert_no_occurrence "#{space}#{tab}\|#{tab}#{space}", "mixed whitespace", true
  end

  def assert_no_occurrence(pattern, error_message, extended=false)
    options = extended ? "-IE" : "-I"
    lines = `git grep #{options} '#{pattern}' | grep -v '^vendor/'`
    assert_not_equal 0, $?.to_i, "#{error_message}:\n#{lines}"
  end

end
