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

class InstanceConfigurationBrowsingTest < ActiveSupport::TestCase
  setup do
    @config = Iqvoc::InstanceConfiguration.instance
  end

  teardown do
    @config = nil
    # TODO: unset singleton?
  end

  test 'should require a setting to be registered upfront' do
    assert_raise Iqvoc::InstanceConfiguration::UnregisteredSetting do
      @config['new_setting_key'] = 'new_setting_value'
    end
  end

  test 'should register settings with defaults' do
    @config.register_setting('ho', 'yuken')
    assert_equal 'yuken', @config['ho']

    @config.register_settings('ha' => 'douken')
    assert_equal 'douken', @config['ha']
  end

  test 'should deregister settings' do
    @config.register_setting('country', 'germany')
    assert_equal 'germany', @config.deregister_setting('country')
    assert_nil @config['germany']
  end

  test 'should validate values' do
    @config.register_setting('foo', 'bar')

    assert_raise(TypeError) { @config['foo'] = nil }
    assert_raise(TypeError) { @config.register_setting('foo', nil) }
    assert_raise(TypeError) { @config.register_setting('foo', Hash.new) }
  end
end
