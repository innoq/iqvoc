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

class FoobarAppender < Iqvoc::Origin::Filters::GenericFilter
  def call(obj, str)
    str = "#{str}_foobar"
    run(obj, str)
  end
end

class OriginTest < ActiveSupport::TestCase
  def test_origin_generation
    assert_match /_[0-9a-z]{16}/, Iqvoc::Origin.new.to_s
  end

  def test_register_custom_filter
    Iqvoc::Origin::Filters.register(:append_foobar, FoobarAppender)
    assert_equal 'trololo_foobar', Iqvoc::Origin.new('trololo').append_foobar.to_s
    assert_match /_[0-9a-z]{16}_foobar/, Iqvoc::Origin.new('trololo').to_s
  end
end
