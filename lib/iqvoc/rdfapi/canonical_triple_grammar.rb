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
    module CanonicalTripleGrammar
      def r_name(context = '')
        //x
      end

      def r_absolute_uri(context = '')
        /(?<#{context}Uri> [^<>\s]+ )/x
      end

      def r_namespaced_origin(context = '')
        /(?<#{context}Prefix> ([A-Za-z][A-Za-z0-9]*)? ) :
         (?<#{context}Origin> [_A-Za-z][A-Za-z0-9]* )/x
      end

      def r_language(context = '')
        /(?<#{context}Language> [a-z]+('-'[a-z0-9]+)*)/x
      end

      def r_string(context = '')
        /(?<#{context}String> [[:print:]]*)/x
      end

      def r_uriref(context = '')
        /<#{r_absolute_uri(context)}>/x
      end

      def r_datatype_string(context = '')
        my_context = context + 'Datatype'
        /(?<#{my_context}>
          "#{r_string(my_context)}"
          \^\^
          #{r_uriref(my_context)}
          )/x
      end

      def r_lang_string(context = '')
        my_context = context + 'Langstring'
        /(?<#{my_context}>
          "#{r_string(my_context)}"
          ( @#{r_language(my_context)} )?
          )/x
      end

      def r_literal(context = '')
        /#{r_lang_string(context)} | #{r_datatype_string(context)}/x
      end

      def r_subject(context = '')
        my_context = context + 'Subject'
        /(?<#{my_context}>
          #{r_namespaced_origin(my_context)}
          )/x
      end

      def r_predicate(context = '')
        my_context = context + 'Predicate'
        /(?<#{my_context}>
          #{r_namespaced_origin(my_context)}
          )/x
      end

      def r_object(context = '')
        my_context = context + 'Object'
        /(?<#{my_context}>
            #{r_namespaced_origin(my_context)} |
            #{r_absolute_uri(my_context)} |
            #{r_literal(my_context)}
          )/x
      end

      def r_triple(context = '')
        /#{r_subject}  [[:blank:]]+
         #{r_predicate}[[:blank:]]+
         #{r_object} /x
      end

      def r_eol
        /\r?\n/
      end

      def r_line(context = '')
        /^
          [[:blank:]]*
          (?<#{context}Triple> #{r_triple})
          [[:blank:]]*
          (#{r_eol})?
        $/x
      end

    end # module CanononicalTripleGrammar
  end # module RDFAPI
end # module Iqvoc

