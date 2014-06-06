# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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

class HygieneTest < ActiveSupport::TestCase

  test 'trailing whitespace' do
    assert_no_occurrence '[[:blank:]]$', 'trailing whitespace'
  end

  test 'mixed whitespace' do
    tab = "\t"
    space = ' '
    assert_no_occurrence "#{space}#{tab}\|#{tab}#{space}", 'mixed whitespace', true
  end

  def assert_no_occurrence(pattern, error_message, extended = false)
    extra_options = extended ? 'E' : ''
    lines = `git grep -In#{extra_options} '#{pattern}' | grep -v '^vendor/'`
    assert_not_equal 0, $?.to_i, "#{error_message}:\n#{lines}"
  end

end
