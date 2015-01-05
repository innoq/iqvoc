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

require 'iqvoc/rdfapi'

module Iqvoc
  class Origin
    attr_accessor :initial_value, :value

    def initialize(value = nil)
      self.initial_value = value
      self.value = "_#{SecureRandom.hex(8)}"
    end

    def valid?
      valid = true

      if blank_node = initial_value.match(Iqvoc::RDFAPI::BLANK_NODE_REGEXP)
        # blank node validation, should not contain special chars
        valid = false if CGI.escape(blank_node[1]) != blank_node[1]
      else
        # regular subject validation

        # should not start with a number
        valid = false if initial_value.match(/^\d.*/)

        # should not contain special chars
        valid = false if CGI.escape(initial_value) != initial_value
      end

      valid
    end

    def to_s
      value
    end
  end
end
