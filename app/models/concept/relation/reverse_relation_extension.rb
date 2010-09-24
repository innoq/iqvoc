module Concept
  module Relation
    module ReverseRelationExtension

      def create_with_reverse_relation(relation_class, target_concept)
        ActiveRecord::Base.transaction do 
          # The one direction
          scope = relation_class.where(:owner_id => proxy_owner.id, :target_id => target_concept.id)
          scope.any? || scope.create!

          # The reverse direction
          scope = relation_class.where(:owner_id => target_concept.id, :target_id => proxy_owner.id)
          scope.any? || scope.create!
        end
      end
      
      def destroy_with_reverse_relation(relation_class, target_concept)
        ActiveRecord::Base.transaction do
          relation_class.where(:owner_id => proxy_owner.id, :target_id => target_concept.id).all.each do |relation|
            relation.destroy
          end

          relation_class.where(:owner_id => target_concept.id, :target_id => proxy_owner.id).all.each do |relation|
            relation.destroy
          end
        end
      end
      
    end
  end
end