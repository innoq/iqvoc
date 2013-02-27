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
    module NTGrammar
      # The following methods represent an augmented implementation of the N-Triples
      # EBNF grammar as found at http://www.w3.org/TR/rdf-testcases/#ntrip_grammar
      # with the addition of some ruby-specific regex-fu.
      #
      # Basically, all relevant token Regexen provide named anchors that can later
      # be accessed as match data. The "context" variables provide a means to
      # build the cartesian product of the resulting state machine (see regex/fsm theory),
      # which resolves ambiguities in sub-regexen. This allows us to simply match
      # each input line in the parser against the "top level" r_line regex and obtain
      # all relevan tokens at once, instead of either re-matching each found token several
      # times in a fragmented manner or building a complex formal parser state machine.

      # The original definition is somewhat strict on the definition of character data.
      # However, we accept any printable character in strings and thus you won't find the
      # formal character, space, eoln etc. definitions here (we use the Ruby equivalent).

      def c_prefixes
        @prefixes.inject([]) do |matches, mapping|
          uri, prefix = *mapping
          match = Regexp.escape(uri)
          matches.push match
        end.join('|')
      end

      def r_name(context = '')
        my_context = context + 'Name'
        /(?<#{my_context}> [A-Za-z][A-Za-z0-9]* )/x
      end

      def r_uri_prefix(context = '')
        /(?<#{context}Prefix> #{c_prefixes} )/x
      end

      def r_uri_origin(context = '')
        /(?<#{context}Origin> [^<>\s]+ )/x
      end

      def r_knowable_uri(context = '')
        /#{r_uri_prefix(context)} #{r_uri_origin(context)}/x
      end

      def r_absolute_uri(context = '')
        r_uri_origin(context)
      end

      def r_uriref(context = '')
        my_context = context + 'Uri'
        /<
          (?<#{my_context}>
             #{r_knowable_uri(my_context)} |
             #{r_absolute_uri(my_context)}
          )
        >/x
      end

      def r_named_node(context = '')
        my_context = context + 'Node'
        / _ : (?<#{my_context}> #{r_name(my_context)} )/x
      end

      def r_subject(context = '')
        my_context = context + 'Subject'
        /(?<#{my_context}>
            #{r_uriref(my_context)} |
            #{r_named_node(my_context)}) /x
      end

      def r_predicate(context = '')
        my_context = context + 'Predicate'
        /(?<#{my_context}> #{r_uriref(my_context)} )/x
      end

      def r_language(context = '')
        /(?<#{context}Language> [a-z]+('-'[a-z0-9]+)* )/x
      end

      def r_string(context = '')
        /(?<#{context}String> [[:print:]]* )/x
      end

      def r_datatype_string(context = '')
        my_context = context + 'Datatype'
        /(?<#{my_context}>
            " #{r_string(my_context)} "
            \^\^
            #{r_uriref(my_context)}
          )/x
      end

      def r_lang_string(context = '')
        my_context = context + 'Langstring'
        /(?<#{my_context}>
          " #{r_string(my_context)} "
          ( @#{r_language(my_context)} )?
          )/x
      end

      def r_literal(context = '')
        /#{r_lang_string(context)} | #{r_datatype_string(context)}/x
      end

      def r_object(context = '')
        my_context = context + 'Object'
        /(?<#{my_context}>
            #{r_uriref(my_context)} |
            #{r_named_node(my_context)} |
            #{r_literal(my_context)}
          )/x
      end

      def r_comment
        /#[^\r\n]*/
      end

      def r_triple
        /#{r_subject}  [[:blank:]]+
         #{r_predicate}[[:blank:]]+
         #{r_object}   [[:blank:]]*
         \.            [[:blank:]]*/x
      end

      def r_eol
        /\r?\n/
      end

      def r_line
        /^
          [[:blank:]]*
          (
            (?<Comment> #{r_comment}) |
            (?<Triple> #{r_triple})
          )
          (#{r_eol})?
        $/x
      end

    end
  end
end

