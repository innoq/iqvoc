# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
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

require 'iqvoc'
require 'iqvoc/origin'
require 'iqvoc/inline_data_helper'
require 'iqvoc/version'
require 'iqvoc/versioning'
require 'iqvoc/deep_cloning'
require 'iqvoc/rankable'
require 'iqvoc/ability'
require 'iqvoc/rdfapi'

ActiveRecord::Base.send :include, Iqvoc::DeepCloning

##### INSTANCE SETTINGS #####

# initialize non-dynamic settings below
# see lib/iqvoc.rb for the list of available setting

unless Rails.env.test?
end
