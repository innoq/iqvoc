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

module Iqvoc

  # provides the interface to configuration settings
  class InstanceConfiguration

    Defaults = {} # XXX: use HashWithIndifferentAccess?

    def self.[](key)
      begin
        setting = ConfigurationSetting.find_by_key(key)
      rescue ActiveRecord::StatementInvalid # pre-migration; table does not exist yet
        setting = nil # use defaults
      end
      return setting ? JSON.load(setting.value) : Defaults[key]
    end

    def self.[]=(key, value)
      validate_value(value) # XXX: doesn't cover defaults

      value = JSON.dump(value)
      if setting = ConfigurationSetting.find_by_key(key) # XXX: inefficient?
        setting.update_attributes(:value => value)
      else
        ConfigurationSetting.create(:key => key, :value => value)
      end

      return value
    end

    # checks whether value type is supported
    def self.validate_value(value)
      if value == nil
        raise TypeError, "nil values not supported"
      end
      unless [String, Fixnum, Float, Array].include?(value.class)
        raise TypeError, "complex values not supported"
      end
    end

  end

end
