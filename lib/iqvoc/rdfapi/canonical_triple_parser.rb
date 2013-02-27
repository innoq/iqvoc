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
  module RDFAPI
    autoload :ParsedTriple,           'iqvoc/rdfapi/parsed_triple'
    autoload :CanonicalTripleGrammar, 'iqvoc/rdfapi/canonical_triple_grammar'

    # parses the iQvoc internal canonical triple format.
    # It ist basically N-Triples with with a simplified TTL syntax.
    class CanonicalTripleParser
      attr_reader :prefixes, :context, :lookup, :blank_nodes

      include CanonicalTripleGrammar

      def initialize(io)
        io.rewind if io.is_a? IO
        @stream   = io
        @context  = {}
        @lookup   = {}
      end

      def each_valid_triple
        self.each_valid_line do |matchdata|
          yield matchdata
        end
      end

      def each_valid_line
        @stream.each_line do |line_data|
          # This does the whole tokenization magic for us. All that's left to to
          # is collect the matchdata tokens and handle the conditions FSM like.
          # To see all possible tokens call r_line.names
          next if line_data.blank?
          matchdata = r_line.match(line_data)

          if matchdata
            yield matchdata
          else
            puts 'ERR: unmatched line data:'
            puts line_data.inspect
          end
        end
      end
    end

  end
end
