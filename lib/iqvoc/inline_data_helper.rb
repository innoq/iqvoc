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

require 'csv'

module Iqvoc
  module InlineDataHelper
    # delimiters for strings representing a list of values - XXX: lacks encapsulation
    JOINER = ', '
    SPLITTER = /[,\n] */

    CSV_OPTIONS = {
      col_sep: ', ',
      quote_char: '"'
    }

    def self.parse_inline_values(inline_values)
      options = CSV_OPTIONS.clone
      options[:col_sep] = options[:col_sep].strip
      begin
        values = inline_values.parse_csv(options)
      rescue CSV::MalformedCSVError => exc
        values = inline_values.parse_csv(CSV_OPTIONS)
      end
      values ? values.map(&:strip) : []
    end

    def self.generate_inline_values(values)
      values.to_csv(CSV_OPTIONS).strip
    end
  end
end
