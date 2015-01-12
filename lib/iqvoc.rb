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

require 'string'
require 'iqvoc/configuration/instance_configuration'
require 'iqvoc/configuration/navigation'
require 'iqvoc/configuration/core'
require 'iqvoc/configuration/concept'
require 'iqvoc/configuration/collection'
require 'iqvoc/configuration/label'
require 'iqvoc/configuration/sync'

module Iqvoc
  unless Iqvoc.const_defined?(:Application)
    require File.join(File.dirname(__FILE__), '../config/engine')
  end

  include Iqvoc::Configuration::Core

  module Concept
    include Iqvoc::Configuration::Concept
  end

  module Collection
    include Iqvoc::Configuration::Collection
  end

  module Label
    include Iqvoc::Configuration::Label
  end

  module Sync
    include Iqvoc::Configuration::Sync
  end
end

# FIXME: For reasons yet unknown, the load hook is executed twice
ActiveSupport.run_load_hooks(:after_iqvoc_config, Iqvoc)
