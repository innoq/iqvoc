module IqvocGlobal
  module ConceptAssociationExtensions
    module PushWithReflectionExtension
      def push_with_reflection_creation(relation_obj)
        ActiveRecord::Base.transaction do
          current_target = Concept.find(relation_obj.target_id)
          target_concept_new_version = Concept.new_version(current_target.origin).first
          prepared_reflection_hash = {:owner_id => relation_obj.target_id, :target_id => proxy_owner.id}

          self << relation_obj
          if target_concept_new_version.present?
            self << relation_obj.class.new(:target_id => target_concept_new_version.id)
            prepared_reflection_hash_new_version = {:owner_id => target_concept_new_version.id, :target_id => proxy_owner.id}
            case proxy_reflection.name.to_s
              when "narrower_relations"
                Broader.create(prepared_reflection_hash)
                Broader.create(prepared_reflection_hash_new_version)
              when "broader_relations"
                Narrower.create(prepared_reflection_hash)
                Narrower.create(prepared_reflection_hash_new_version)
              when "related_relations"
                Related.create(prepared_reflection_hash)
                Related.create(prepared_reflection_hash_new_version)
            end
          else
            case proxy_reflection.name.to_s
              when "narrower_relations"
                Broader.create(prepared_reflection_hash)
              when "broader_relations"
                Narrower.create(prepared_reflection_hash)
              when "related_relations"
                Related.create(prepared_reflection_hash)
            end
          end
        end
      end
    end

    module DestroyReflectionExtension
      def destroy_reflection(relation_obj)
        target_concept = Concept.find(relation_obj.target_id)
        target_concept_new_version = Concept.new_version(target_concept.origin).first
        ActiveRecord::Base.transaction do
          if target_concept_new_version.present?
            case proxy_reflection.name.to_s
              when "narrower_relations"
                raise ActiveRecord::RecordNotFound unless Broader.find_by_owner_id_and_target_id(target_concept.id, relation_obj.owner_id).destroy && Broader.find_by_owner_id_and_target_id(target_concept_new_version.id, relation_obj.owner_id).destroy
              when "broader_relations"
                raise ActiveRecord::RecordNotFound unless Narrower.find_by_owner_id_and_target_id(target_concept.id, relation_obj.owner_id).destroy && Narrower.find_by_owner_id_and_target_id(target_concept_new_version.id, relation_obj.owner_id).destroy
              when "related_relations"
                raise ActiveRecord::RecordNotFound unless Related.find_by_owner_id_and_target_id(target_concept.id, relation_obj.owner_id).destroy && Related.find_by_owner_id_and_target_id(target_concept_new_version.id, relation_obj.owner_id).destroy
            end
            raise ActiveRecord::RecordNotFound unless proxy_reflection.class_name.constantize.find_by_owner_id_and_target_id(relation_obj.owner_id, target_concept_new_version.id).destroy && relation_obj.destroy
            true
          else
            case proxy_reflection.name.to_s
              when "narrower_relations"
                raise ActiveRecord::RecordNotFound unless Broader.find_by_owner_id_and_target_id(target_concept.id, relation_obj.owner_id).destroy
              when "broader_relations"
                raise ActiveRecord::RecordNotFound unless Narrower.find_by_owner_id_and_target_id(target_concept.id, relation_obj.owner_id).destroy
              when "related_relations"
                raise ActiveRecord::RecordNotFound unless Related.find_by_owner_id_and_target_id(target_concept.id, relation_obj.owner_id).destroy
            end
            raise ActiveRecord::RecordNotFound unless relation_obj.destroy
            true
          end
        end
      end
    end
  end
end