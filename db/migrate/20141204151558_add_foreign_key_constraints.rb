class AddForeignKeyConstraints < ActiveRecord::Migration
  def change
    # user foreign keys
    add_foreign_key :concepts, :users, column: 'locked_by', on_delete: :nullify, on_update: :cascade
    add_foreign_key :exports, :users, column: 'user_id', on_delete: :nullify, on_update: :cascade
    add_foreign_key :imports, :users, column: 'user_id', on_delete: :nullify, on_update: :cascade

    # concept/collection foreign keys
    add_foreign_key :concept_relations, :concepts, column: 'owner_id', on_update: :cascade
    add_foreign_key :concept_relations, :concepts, column: 'target_id', on_update: :cascade
    add_foreign_key :collection_members, :concepts, column: 'collection_id', on_update: :cascade
    add_foreign_key :collection_members, :concepts, column: 'target_id', on_update: :cascade
    add_foreign_key :labelings, :concepts, column: 'owner_id', on_update: :cascade
    add_foreign_key :matches, :concepts, column: 'concept_id', on_delete: :cascade, on_update: :cascade
    add_foreign_key :notations, :concepts, column: 'concept_id', on_update: :cascade
    add_foreign_key :notes, :concepts, column: 'owner_id', on_delete: :cascade, on_update: :cascade

    # labels
    add_foreign_key :labelings, :labels, column: 'target_id',  on_delete: :cascade, on_update: :cascade

    # notes foreign keys
    add_foreign_key :note_annotations, :notes, column: 'note_id', on_delete: :cascade, on_update: :cascade
  end
end
