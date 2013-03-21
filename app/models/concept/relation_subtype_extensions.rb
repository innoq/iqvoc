# encoding: UTF-8

module Concept
  module RelationSubtypeExtensions
    extend Concept::Relation::ReverseRelationExtension
#     extend Concept::TypedHasManyExtension

    def find_by_target_and_class(target_obj, target_class)
      self.for_class(target_class).find{|rel| rel.target == target_obj || rel.target_id == target_obj.id }
    end

    def by_id_and_rank(class_name)
      self.for_class(class_name).each_with_object({}) { |rel, hsh| hsh[rel.target] = rel.rank }
    end

    def by_id(class_name)
      self.for_class(class_name).map {|l| l.target.origin }.join(Iqvoc::InlineDataHelper::JOINER)
    end

  end
end
