class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table "classifications", :force => true do |t|
      t.integer  "owner_id"
      t.integer  "target_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "classifications", ["owner_id", "target_id"], :name => "index_classifications_on_owner_id_and_target_id"

    create_table "classifiers", :force => true do |t|
      t.string   "title"
      t.string   "description"
      t.string   "notation"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "classifiers", ["notation"], :name => "index_classifiers_on_notation"

    create_table "concept_relations", :force => true do |t|
      t.string   "type"
      t.integer  "owner_id"
      t.integer  "target_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "concept_relations", ["owner_id", "target_id"], :name => "index_semantic_relations_on_owner_id_and_target_id"
    add_index "concept_relations", ["target_id"], :name => "index_semantic_relations_on_target_id"

    create_table "concepts", :force => true do |t|
      t.string   "type"
      t.string   "origin"
      t.integer  "rev",                               :default => 1
      t.date     "published_at"
      t.integer  "published_version_id"
      t.integer  "locked_by"
      t.date     "expired_at"
      t.date     "follow_up"
      t.boolean  "to_review"
      t.date     "rdf_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "concepts", ["origin"], :name => "index_concepts_on_origin"
    add_index "concepts", ["published_version_id"], :name => "index_concepts_on_published_version_id"

    create_table "label_relations", :force => true do |t|
      t.string   "type"
      t.integer  "domain_id"
      t.integer  "range_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "label_relations", ["domain_id", "range_id", "type"], :name => "index_label_relations_on_domain_id_and_range_id_and_type"
    add_index "label_relations", ["type"], :name => "index_label_relations_on_type"

    create_table "labelings", :force => true do |t|
      t.string   "type"
      t.integer  "owner_id"
      t.integer  "target_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "labelings", ["owner_id", "target_id", "type"], :name => "index_labelings_on_owner_id_and_target_id_and_type"
    add_index "labelings", ["owner_id", "target_id"], :name => "index_labelings_on_owner_id_and_target_id"
    add_index "labelings", ["type"], :name => "index_labelings_on_type"

    create_table "labels", :force => true do |t|
      t.string   "type"
      t.string   "origin"
      t.string   "language"
      t.string   "value",                :limit => 1024
      t.integer  "rev",                  :default => 1
      t.integer  "published_version_id"
      t.date     "published_at"
      t.integer  "locked_by"
      t.date     "expired_at"
      t.date     "follow_up"
      t.boolean  "to_review"
      t.date     "rdf_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "labels", ["language"], :name => "index_labels_on_owner_id_and_language"
    add_index "labels", ["origin"], :name => "index_labels_on_origin"
    add_index "labels", ["value"], :name => "index_labels_on_value", :length => {"value"=>255}
    add_index "labels", ["published_version_id"], :name => "index_labels_on_published_version_id"

    create_table "matches", :force => true do |t|
      t.integer  "concept_id"
      t.string   "type"
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "matches", ["concept_id", "type"], :name => "index_matches_on_concept_id_and_type"
    add_index "matches", ["concept_id"], :name => "index_matches_on_concept_id"
    add_index "matches", ["type"], :name => "index_matches_on_type"

    create_table "note_annotations", :force => true do |t|
      t.integer  "note_id"
      t.string   "identifier", :limit => 50
      t.string   "value",      :limit => 1024
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "note_annotations", ["note_id"], :name => "index_note_annotations_on_note_id"

    create_table "notes", :force => true do |t|
      t.string   "language",   :limit => 2
      t.string   "value",      :limit => 1024
      t.string   "type",       :limit => 50
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "owner_id"
      t.string   "owner_type",                 :null => false
    end

    add_index "notes", ["owner_id", "language"], :name => "index_notes_on_owner_id_and_language"
    add_index "notes", ["owner_id", "owner_type", "type"], :name => "index_notes_on_owner_id_and_owner_type_and_type"
    add_index "notes", ["type"], :name => "index_notes_on_type"

    create_table "users", :force => true do |t|
      t.string   "forename"
      t.string   "surname"
      t.string   "email"
      t.string   "crypted_password"
      t.boolean  "active"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "password_salt"
      t.string   "persistence_token"
      t.string   "perishable_token"
      t.string   "role"
      t.string   "telephone_number"
    end
  end

  def self.down
  end
end
