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

$LOAD_PATH << 'lib/iqvoc/rdfapi'

module Iqvoc
  module RDFAPI
    autoload :NTGrammar, 'iqvoc/rdfapi/nt_grammar'
    autoload :NTParser, 'iqvoc/rdfapi/nt_parser'
    autoload :CanonicalTripleGrammar, 'iqvoc/rdfapi/canonical_triple_grammar'
    autoload :CanonicalTripleParser, 'iqvoc/rdfapi/canonical_triple_parser'
    autoload :ParsedTriple, 'iqvoc/rdfapi/parsed_triple'

    protected

    class ObjectInstanceBuilder
      # FIXME: yepp, this is not thread safe -- fix this later.
      @@lookup_by_origin = {}

      def self.by_origin(origin, klass = nil)
        @@lookup_by_origin[origin.to_s] ||= begin
          thing = (klass || ::Concept::Base).find_by_origin(origin)
          if thing
            actual_klass = thing.type ? thing.type.constantize : ::Concept::Base
            @@lookup_by_origin[origin.to_s] = thing.class == actual_klass ? thing : thing.becomes(actual_klass) # cast object to its actual type
          end
        end
      end

      def self.build_from_parsed_tokens(tokens)
        raise "expected predicate to be rdf:type but #{tokens[:Predicate]} was found." unless ['rdf:type', self].include? tokens[:Predicate]

        klass  = Iqvoc::RDFAPI::OBJECT_DICTIONARY[tokens[:Object]]
        origin = tokens[:SubjectOrigin]
        thing  = self.by_origin(origin, klass)
        if thing.nil?
          thing = @@lookup_by_origin[origin.to_s] = klass.new(:origin => origin)
        end
        thing
      end
    end

    class ObjectPublisher
      def self.build_from_parsed_tokens(tokens)
        if rdf_subject = RDFAPI.cached(tokens[:SubjectOrigin])
          rdf_subject.published_at = tokens[:ObjectDatatypeString]
        end
        rdf_subject
      end
    end

    # lists of class names that are supported for Triple import.
    # we allow the user to define these names in Iqvoc::Config.
    FIRST_LEVEL_OBJECT_CLASSES  = [Iqvoc::Concept.base_class, Iqvoc::Collection.base_class]
    SECOND_LEVEL_OBJECT_CLASSES = Iqvoc::Concept.labeling_classes.keys +
                                  Iqvoc::Concept.note_classes +
                                  Iqvoc::Concept.relation_classes +
                                  Iqvoc::Concept.match_classes +
                                  Iqvoc::Collection.member_classes

    public

    # lookup table for RDF object names to Ruby class names.
    # Ex: 'skos:Concept' => Concept::SKOS::Base
    OBJECT_DICTIONARY = FIRST_LEVEL_OBJECT_CLASSES.inject({}) do |hash, klass|
      hash[klass.rdf_internal_name] = klass
      hash
    end

    # lookup table for RDF predicate names to Ruby class names.
    # Ex: 'skos:prefLabel' => Labeling::SKOS::PrefLabel
    internal_mapping = {
      'rdf:type'          => ObjectInstanceBuilder,
      'iqvoc:publishedAt' => ObjectPublisher
    }
    PREDICATE_DICTIONARY = SECOND_LEVEL_OBJECT_CLASSES.inject(internal_mapping) do |hash, klass|
      hash[klass.rdf_internal_name] = klass
      hash
    end

    def self.cached(origin)
      ObjectInstanceBuilder.by_origin(origin)
    end

    # take an internal canonical triple and devour it
    def self.eat(parsed_triple_data)
      target = PREDICATE_DICTIONARY[parsed_triple_data[:Predicate]]

      if target
        target.build_from_parsed_tokens(parsed_triple_data)
      else
        puts "ERR: #{parsed_triple_data[:Predicate]} maps to no target"
      end
    end

    # Simple multiline interface, accepts a string or an IO to be read.
    # It reads the input line by line and feeds it to RDFAPI.devour, saving the result.
    # This is thus not a full-blown triple importer, since it has no 'state'.
    # Which also means: you have to provide the triples in an order where no statements
    # about first level objects (concepts, collections, SKOSXL labels etc.) precede
    # the definition of those objects themselves.
    # Triples may consist of explicit Ruby class names or namespaced RDF-Triples.
    # If you want to import generic N-Triples (With complete URIs instead of just namesoaces),
    # use RDFAPI.parse_nt.
    def self.parse_triples(io_or_string)
      parser = CanonicalTripleParser.new(io_or_string)
      parser.each_valid_triple do |line|
        if block_given?
          yield triple
        else
          result = self.eat(line)
          result.save or puts "ERROR saving triple: #{result.errors.inspect}"
        end
      end
    end

    def self.parse_triple(str)
      result = CanonicalTripleParser.parse_single_line(str)
      if result
        self.eat(result)
      else
        puts "#{str.inspect} is not a valid triple line."
        nil
      end
    end

    def self.<<(str)
      self.parse_triples(str)
    end

    # N-Triples importer. This basically instantiates an NTParser and
    # feeds whatever IO or String object you pass as the first argument.
    # The required second argument denotes the default namespace URI,
    # i.e. the one of the triples you want to import (others will be ignored).
    def self.parse_nt(str_or_io, default_namespace_url)
      unless str_or_io.is_a? IO
        str_or_io = StringIO.new(str_or_io)
      end
      parser = NTParser.new str_or_io, default_namespace_url

      parser.each_valid_triple do |triple|
        if block_given?
          yield triple
        else
          self.eat(triple).save
        end
      end
    end

  end
end
