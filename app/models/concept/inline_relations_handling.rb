# encoding: UTF-8

# Copyright 2013 innoQ Deutschland GmbH
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

module Concept
  module InlineRelationsHandling
    extend ActiveSupport::Concern

    included do
      before_validation :process_inline_relations

      attr_writer :inline_relations
    end

    def inline_relations(reload = false)
      if reload
        @inline_relations = load_inline_relations
      else
        @inline_relations ||= load_inline_relations
      end
    end

    # ??? is this still needed anywhere?
    def inline_relations_by_id(relation_rdf_type)
      ActiveSupport::Deprecation.warn 'please call concept.relations.by_id(relation_name) in the future'
      @inline_relations[relation_rdf_type] || self.relations.by_id(relation_rdf_type)
    end

    protected

    def load_inline_relations
      Hash.new.with_indifferent_access.tap do |r|
        self.relations.each do |relation|
          r[relation.rdf_internal_name] ||= Hash.new.with_indifferent_access
          r[relation.rdf_internal_name][relation.id.to_s] = relation.attributes.with_indifferent_access
        end
      end
    end

    # Process inline relations
    #
    # NB: rankable relations' target origins may include an embedded rank,
    # delimited by a colon
    #
    # Examples:
    # regular:  {'skos:someRelation' => ['origin1', 'origin2']}
    # rankable: {'skos:someRelation=> ['origin1:100', 'origin2:90']}
    def process_inline_relations
      self.inline_relations.each do |rdf_type, new_origins|
        # Split comma-separated origins and clean up parameter strings
        new_origins = Iqvoc::InlineDataHelper.split(new_origins)

        # Extract embedded ranks (if any) from origin strings (e.g. "origin1:100")
        # => { 'origin1' => nil, 'origin2' => 90 }
        new_origins = new_origins.each_with_object({}) do |e, hsh|
          key, value = e.split(':') # NB: defaults to nil if no rank is provided
          hsh[key] = value
        end

        # Destroy elements of the given concept relation
        self.relations.for_rdf_class(rdf_type).each do |rel|
          self.relations.destroy_later(rel)
          rel.reverse_relations.each do |obj|
            self.referenced_relations.destroy_later(obj)
          end
        end

        # Rebuild concept relations
        # This is necessary because changing the rank of an already assigned relation
        # would otherwise be ignored.
        new_origins.each_pair do |origin, rank|
          ActiveRecord::Base.transaction do
            tokens = {:ObjectOrigin => origin, :Predicate => rdf_type}
            Concept::Relation::SKOS::Base.build_from_parsed_tokens(tokens, :subject_instance => self, :object_rank => rank).save
          end
        end
      end
    end

  end
end
