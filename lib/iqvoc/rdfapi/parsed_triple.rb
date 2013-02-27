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
    class ParsedTriple

      def initialize(parser, matchdata)
        @parser = parser
        @m      = matchdata
        @internal_data = {}
      end

      def [](key)
        @internal_data[key.to_sym]
      end

      def ok?
        self.subject != :skip and
            self.predicate != :skip and
            self.object != :skip
      end

      def subject
        @internal_data[:Subject] ||= begin
          if @m[:SubjectNodeName] # blank node
            @parser.named_nodes[@m[:SubjectNodeName]] ||= Iqvoc::Origin.new(@m[:SubjectNodeName])
          elsif @parser.prefixes[@m[:SubjectUriPrefix]] == '' # subject we want to import
            ":#{Iqvoc::Origin.new(@m[:SubjectUriOrigin])}"
          else
            puts "ignoring unknown prefix #{@m[:SubjectUriPrefix]}."
            :skip
          end
        end
      end

      def predicate
        @internal_data[:Predicate] ||= begin
          if prefix = @parser.prefixes[@m[:PredicateUriPrefix]] # known prefix
            "#{prefix}:#{@m[:PredicateUriOrigin]}"
          else
            :skip
          end
        end
      end

      def object
        @internal_data[:Object] ||= begin
          if @m[:ObjectNodeName] # blank node
            @parser.named_nodes[@m[:ObjectNodeName]] ||= Iqvoc::Origin.new(@m[:ObjectNodeName])
          elsif prefix = @parser.prefixes[@m[:ObjectUriPrefix]]
            "#{prefix}:#{Iqvoc::Origin.new(@m[:ObjectUriOrigin])}"
          elsif @m[:ObjectLangstringString] # string literal
            @m[:ObjectLangstring]
          else
            :skip
          end
        end
      end

    end # class ParsedTriple
  end # module RDFAPI
end # module Iqvoc
