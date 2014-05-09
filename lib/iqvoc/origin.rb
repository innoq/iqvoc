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

# Provides utilities to replace special chars etc in
# texts to generate a valid turtle compatible id (an url slug):
# Iqvoc::Origin.new("fübar").to_s # => "fuebar"
#
# Note that .to_s respects eventually previously executed method chains
# Just calling "to_s" runs all registered filters.
# Prepending "to_s" with a specific filter method only runs the given filter:
# Iqvoc::Origin.new("fübar").replace_umlauts.to_s # => "fuebar"
#
# Adding your own filter classes is easy:
# class FoobarStripper < Iqvoc::Origin::Filters::GenericFilter
#   def call(obj, str)
#     str = str.gsub("foobar", "")
#     run(obj, str)
#   end
# end
# Iqvoc::Origin::Filters.register(:strip_foobars, FoobarStripper)
#
module Iqvoc
  class Origin
    module Filters
      class GenericFilter
        def call(obj, str)
          # do what has to be done with str
          # afterwards: make sure to pass "obj" and your modified "str" to "run()"
          run(obj, str)
        end

        def run(obj, str)
          obj.tap do |obj|
            obj.value = str
          end
        end
      end

      class UriConformanceFilter < GenericFilter
        def call(obj, str)
          str = str.parameterize # basic url conformance

          # prefix with '_' if origin starts with digit
          str = str.gsub(/^[0-9].*$/) do |match|
            "_#{match}"
          end
          run(obj, str)
        end
      end

      @filters = {}
      @filters[:uri_conformance_filter] = UriConformanceFilter

      def self.register(name, klass)
        @filters[name.to_sym] = klass
      end

      def self.registered
        @filters
      end
    end

    attr_accessor :initial_value, :value, :filters

    def initialize(value)
      self.initial_value = value.to_s
      self.value = initial_value
    end

    def touched?
      value != initial_value
    end

    def run_filters!
      Filters.registered.each do |key, filter_class|
        filter_class.new.call(self, value)
      end
    end

    def method_missing(meth, *args)
      if Filters.registered.keys.include?(meth.to_sym)
        Filters.registered[meth.to_sym].new.call(self, value)
      else
        super
      end
    end

    def to_s
      return value if touched?
      run_filters!
      value
    end

    def inspect
      "#<Iqvoc::Origin:0x%08x>" % object_id
    end

  end
end
