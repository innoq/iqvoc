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

    # lists of class names that are supported for Triple import.
    # we allow the user to define these names in Iqvoc::Config.
    FIRST_LEVEL_OBJECT_CLASSES  = [Iqvoc::Concept.base_class, Iqvoc::Collection.base_class]
    SECOND_LEVEL_OBJECT_CLASSES = Iqvoc::Concept.labeling_classes.keys +
                                  Iqvoc::Concept.note_classes +
                                  Iqvoc::Concept.relation_classes +
                                  Iqvoc::Concept.match_classes +
                                  Iqvoc::Collection.member_classes

    # lookup table for RDF object names to Ruby class names.
    # Ex: 'skos:Concept' => Concept::SKOS::Base
    OBJECT_DICTIONARY = FIRST_LEVEL_OBJECT_CLASSES.inject({}) do |hash, klass|
      hash["#{klass.rdf_namespace}:#{klass.rdf_class}"] = klass
      hash
    end

    # lookup table for RDF predicate names to Ruby class names.
    # Ex: 'skos:prefLabel' => Labeling::SKOS::PrefLabel
    PREDICATE_DICTIONARY = SECOND_LEVEL_OBJECT_CLASSES.inject({}) do |hash, klass|
      hash["#{klass.rdf_namespace}:#{klass.rdf_predicate}"] = klass
      hash
    end

    # Take a single triple and import it into the relational data model.
    # The triple may either be passed as a single string or as three separate
    # arguments, denoting Subject, predicate and Object in that order.
    # Subject and Object can be a String denoting an 'origin' or an Instance
    # of any SKOS class. Some examples:
    # Subject may be:
    #  * ':monkey' (default namespace with origin 'monkey')
    #  * 'monkey' (default namespace may be omitted)
    #  * <Concept::SKOS::Base @origin='monkey'...> (an instance of a concept class)
    # Predicate may be:
    #  * 'rdf:type', 'skos:prefLabel' (an RDF class name)
    #  * Collection::Member::SKOS::Base (a Ruby relation class)
    #  * 'Collection::Member::SKOS::Base' (a Ruby relation class name)
    # Object may be:
    #  * 'skos:Concept' (an RDF class name)
    #  * Concept::SKOS::Base (a ruby class)
    #  * 'Concept::SKOS::Base' (a ruby class name)
    #  * <Concept::SKOS::Base @origin='animal'...> (an instance of a concept class)
    #  * '"Monkey"@en' (a String literal)
    #  * ':animal' (default namespace with origin 'animal')
    #  * 'animal' (default namespace may be omitted)
    def self.devour(rdf_subject_or_string, rdf_predicate = nil, rdf_object = nil)
      if rdf_predicate.nil? and rdf_object.nil?
        # we have a single string to parse and interpret
        rdf_subject, rdf_predicate, rdf_object = rdf_subject_or_string.split(/\s+/, 3)
      else
        rdf_subject = rdf_subject_or_string
      end

      if rdf_subject.is_a? String
        rdf_subject = rdf_subject.sub(/^:/, '') # strip default namespace
      end

      if rdf_object.is_a? String
        rdf_object = rdf_object.sub(/^:/, '') # strip default namespace
      end

      case rdf_predicate
      when 'a', 'rdf:type'
        case rdf_object
        when String
          target = OBJECT_DICTIONARY[rdf_object] || rdf_object.constantize
        else
          target = rdf_object
        end
        target.find_or_initialize_by_origin(rdf_subject)
      when String
        target = PREDICATE_DICTIONARY[rdf_predicate] || rdf_predicate.constantize
        target.build_from_rdf(rdf_subject, target, rdf_object)
      else # is a class
        rdf_predicate.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
      end
    end

    # take an internal canonical triple and devour it
    def self.eat(parsed_triple_data)
      case parsed_triple_data[:Predicate]
      when 'a', 'rdf:type'
        target = OBJECT_DICTIONARY[parsed_triple_data[:Object]]
      else
        target = PREDICATE_DICTIONARY[parsed_triple_data[:Predicate]]
      end

      if target
        target.build_from_rdf(parsed_triple_data[:Subject], parsed_triple_data[:Predicate], parsed_triple_data[:Object])
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
        result = self.eat(line)
        result.save or puts "ERROR saving triple: #{result.errors.inspect}"
      end
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
