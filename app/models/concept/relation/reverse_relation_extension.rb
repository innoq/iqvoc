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

module Concept
  module Relation
    module ReverseRelationExtension

      def create_with_reverse_relation(target_concept, attributes = {})
        relation_class = proxy_association.reflection.class_name.constantize
        ActiveRecord::Base.transaction do
          # The one direction
          scope = relation_class.where(:owner_id => proxy_association.owner.id, :target_id => target_concept.id)
          attributes = attributes.except(:rank) unless relation_class.rankable?
          scope.any? || scope.create!(attributes)

          # The reverse direction
          scope = relation_class.reverse_relation_class.where(:owner_id => target_concept.id, :target_id => proxy_association.owner.id)
          scope.any? || scope.create!(attributes)
        end
      end

      def destroy_with_reverse_relation(target_concept)
        relation_class = proxy_association.reflection.class_name.constantize
        ActiveRecord::Base.transaction do
          relation_class.where(:owner_id => proxy_association.owner.id, :target_id => target_concept.id).all.each do |relation|
            relation.destroy
          end

          relation_class.reverse_relation_class.where(:owner_id => target_concept.id, :target_id => proxy_association.owner.id).all.each do |relation|
            relation.destroy
          end
        end
      end

    end
  end
end
