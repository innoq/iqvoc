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

require 'singleton'

# provides the interface to configuration settings
module Iqvoc
  module Configuration
    class InstanceConfiguration
      include Singleton

      attr_reader :defaults # XXX: dangerous (mutable object)

      class UnregisteredSetting < ArgumentError
        def to_s
          'A setting needs to be registered with register_setting before it can be used.'
        end
      end

      def initialize
        @defaults = {} # default settings
        @records = {} # customized (non-default) settings
        @settings = {} # current settings, using defaults as fallback
        # NB: cannot cache immediately because defaults need to be registered first
      end

      # convenience wrapper for `register_setting` batch operations
      # accepts a hash of key / default value pairs
      def register_settings(settings)
        settings.each do |key, default_value|
          register_setting(key, default_value)
        end
      end

      # create or update a default setting
      def register_setting(key, default_value)
        self.class.validate_value(default_value)

        @defaults[key] = default_value

        # update cache
        @settings[key] = @records[key] || default_value
      end

      # remove a default setting
      # returns nil if setting does not exist
      # NB: does *not* delete configuration settings from the database
      def deregister_setting(key)
        res = @defaults.delete(key)

        # update cache
        @settings.delete(key)

        return res
      end

      # retrieve individual setting, using default value as fallback
      def [](key)
        initialize_cache unless @initialized
        return @settings[key]
      end

      # store individual customized setting
      def []=(key, value)
        raise UnregisteredSetting unless @defaults.include?(key)
        self.class.validate_value(value)

        json = JSON.dump([value])[1..-2] # temporary array wrapper ensures valid JSON text
        if setting = ConfigurationSetting.find_by_key(key)
          setting.update_attributes(value: json)
        else
          ConfigurationSetting.create(key: key, value: json)
        end

        # update cache
        @records[key] = value
        @settings[key] = value

        return value
      end

      # populate settings caches
      # (subsequent updates will happen automatically via the respective setters)
      def initialize_cache
        return false unless ConfigurationSetting.table_exists? # pre-migration

        # cache customized settings
        ConfigurationSetting.all.each do |setting|
          @records[setting.key] = JSON.load("[#{setting.value}]")[0] # temporary array wrapper ensures valid JSON text
        end

        # cache current settings
        @defaults.each do |key, default_value|
          value = @records[key]
          @settings[key] = value.nil? ? default_value : value
        end

        @initialized = true
      end

      # checks whether value type is supported
      def self.validate_value(value) # TODO: compare type to default's? (cf. controller)
        if value == nil
          raise TypeError, 'nil values not supported'
        end
        unless [TrueClass, FalseClass, String, Fixnum, Float, Array].include?(value.class)
          raise TypeError, 'complex values not supported'
        end
      end
    end
  end
end
