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

module Concept
  module InlineRelationsHandling
    extend ActiveSupport::Concern

    included do
      after_save :process_inline_relations

      attr_writer :inline_relations
    end

    def inline_relations
      @inline_relations ||= {}
    end

    def inline_relations_by_id(relation_rdf_type)
      ActiveSupport::Deprecation.warn 'please call concept.relations.by_id(relation_name) in the future'
      @inline_relations[relation_rdf_type] || self.relations.by_id(relation_rdf_type)
    end

    protected

    # Process inline relations
    #
    # NB: rankable relations' target origins may include an embedded rank,
    # delimited by a colon
    #
    # Examples:
    # regular:  {'relation_name' => ['origin1', 'origin2']}
    # rankable: {'relation_name' => ['origin1:100', 'origin2:90']}
    def process_inline_relations
      self.inline_relations.each do |relation_rdf_type, new_origins|
        # Split comma-separated origins and clean up parameter strings
        new_origins = new_origins.split(Iqvoc::InlineDataHelper::SPLITTER).map(&:squish)

        # Extract embedded ranks (if any) from origin strings (e.g. "origin1:100")
        # => { 'origin1' => nil, 'origin2' => 90 }
        new_origins = new_origins.each_with_object({}) do |e, hsh|
          key, value = e.split(':') # NB: defaults to nil if no rank is provided
          hsh[key] = value
        end

        # Destroy elements of the given concept relation
        self.relations.for_rdf_class(relation_rdf_type).each do |rel|
          # TODO: move into own method
          ActiveRecord::Base.transaction do
            rel.class.reverse_relation_class.where(:owner_id => rel.target_id, :target_id => rel.owner_id).each &:destroy
            self.relations.delete(rel.destroy)
          end
        end

        # Rebuild concept relations
        # This is necessary because changing the rank of an already assigned relation
        # would otherwise be ignored.
        new_origins.each_pair do |origin, rank|
          ActiveRecord::Base.transaction do
            tokens = {:ObjectOrigin => origin, :Predicate => relation_rdf_type}
            Concept::Relation::SKOS::Base.build_from_parsed_tokens(tokens, :subject_instance => self, :object_rank => rank).save
          end
        end
      end
    end

  end
end
