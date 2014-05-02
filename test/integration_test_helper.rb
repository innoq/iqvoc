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
require 'capybara/rails'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'webmock'
require 'test_helper'
require 'authentication'

Capybara.javascript_driver = :poltergeist

WebMock.allow_net_connect! # required for integration tests

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Authentication
end
