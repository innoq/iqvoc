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

require 'singleton'

module Iqvoc

  # provides the interface to configuration settings
  class InstanceConfiguration
    include Singleton

    Defaults = {} # XXX: use HashWithIndifferentAccess?

    def [](key)
      cache_settings unless @settings
      return @settings[key]
    end

    def []=(key, value)
      raise ArgumentError unless Defaults.include?(key)
      self.class.validate_value(value) # XXX: doesn't cover defaults

      json = JSON.dump(value)
      if setting = ConfigurationSetting.find_by_key(key)
        setting.update_attributes(:value => json)
      else
        ConfigurationSetting.create(:key => key, :value => json)
      end

      # update cache
      @settings[key] = value

      return value
    end

    # generate hash of all settings, assuming default values where no records exist
    def cache_settings
      return @settings if @settings

      # load customized settings, indexed by key
      db_settings = ConfigurationSetting.all rescue {} # database table might not exist yet (pre-migration)
      db_settings = db_settings.each_with_object({}) { |setting, hsh|
        hsh[setting.key] = JSON.load(setting.value)
      }

      # use default as fallback if no customized setting exists
      @settings = Defaults.each_with_object({}) { |(key, default_value), hsh|
        hsh[key] = db_settings[key] || default_value
      }
    end

    # checks whether value type is supported
    def self.validate_value(value) # TODO: compare type to default's? (cf. controller)
      if value == nil
        raise TypeError, "nil values not supported"
      end
      unless [String, Fixnum, Float, Array].include?(value.class)
        raise TypeError, "complex values not supported"
      end
    end

  end

end
