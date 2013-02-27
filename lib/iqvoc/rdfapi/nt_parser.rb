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
    autoload :ParsedTriple, 'iqvoc/rdfapi/parsed_triple'

    class NTParser < TripleParser
      include NTGrammar

      def initialize(io, default_namespace_url)
        super(io)
        @blank_nodes = {}
        @prefixes    = {
          'http://www.w3.org/2004/02/skos/core#'        => 'skos',
          'http://www.w3.org/2008/05/skos#'             => 'skos',
          'http://www.w3.org/1999/02/22-rdf-syntax-ns#' => 'rdf',
          default_namespace_url                         => ''
        }
        # Add the namespaces specified in the Iqvoc config
        Iqvoc.rdf_namespaces.each do |pref, uri|
          @prefixes[uri] = "#{pref.to_s}"
        end
      end

      def each_valid_triple
        self.each_valid_line do |matchdata|
          if matchdata[:Comment]
            puts "ignoring comment: #{matchdata[:Comment]}"
          elsif matchdata[:Triple]
            puts "processing triple #{matchdata[:Triple]}"
            triple = ParsedTriple.new(self, matchdata)
            if triple.ok?
              yield triple.subject, triple.predicate, triple.object if block_given?
            else
              next
            end
          else
            next
          end
        end
      end # each_valid_triple

    end # class NTParser
  end # module RDFAPI
end # module Iqvoc
