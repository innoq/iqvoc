# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100923063421) do

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

  create_table "compound_form_contents", :force => true do |t|
    t.integer  "compound_form_id"
    t.integer  "label_id"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "compound_form_contents", ["compound_form_id", "label_id"], :name => "index_compound_form_contents_on_compound_form_id_and_label_id"

  create_table "compound_forms", :force => true do |t|
    t.integer  "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "compound_forms", ["domain_id"], :name => "index_compound_forms_on_domain_id"

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin"
    t.string   "status"
    t.string   "classified"
    t.string   "country_code",         :limit => 4
    t.integer  "rev",                               :default => 1
    t.date     "published_at"
    t.integer  "locked_by"
    t.date     "expired_at"
    t.date     "follow_up"
    t.boolean  "to_review"
    t.date     "rdf_updated_at"
    t.integer  "published_version_id"
  end

  add_index "concepts", ["origin"], :name => "index_concepts_on_origin"

  create_table "inflectionals", :force => true do |t|
    t.integer  "label_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inflectionals", ["label_id"], :name => "index_inflectionals_on_label_id"
  add_index "inflectionals", ["value"], :name => "index_inflectionals_on_value"

  create_table "label_relations", :force => true do |t|
    t.integer  "domain_id"
    t.integer  "range_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "label_relations", ["domain_id", "range_id", "type"], :name => "index_label_relations_on_domain_id_and_range_id_and_type"
  add_index "label_relations", ["type"], :name => "index_label_relations_on_type"

  create_table "labelings", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "target_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "labelings", ["owner_id", "target_id", "type"], :name => "index_labelings_on_owner_id_and_target_id_and_type"
  add_index "labelings", ["type"], :name => "index_labelings_on_type"

  create_table "labels", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language"
    t.string   "value",                :limit => 1024
    t.string   "base_form"
    t.string   "inflectional_code"
    t.string   "part_of_speech"
    t.string   "status"
    t.string   "origin"
    t.integer  "rev",                                  :default => 1
    t.date     "published_at"
    t.integer  "locked_by"
    t.date     "expired_at"
    t.date     "follow_up"
    t.string   "endings"
    t.boolean  "to_review"
    t.date     "rdf_updated_at"
    t.string   "type"
    t.integer  "published_version_id"
  end

  add_index "labels", ["origin"], :name => "index_labels_on_origin"
  add_index "labels", ["value"], :name => "index_labels_on_value"

  create_table "lexical_variants", :force => true do |t|
    t.integer  "owner_id"
    t.string   "type"
    t.string   "language",   :limit => 2
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lexical_variants", ["owner_id", "type"], :name => "index_lexical_variants_on_owner_id_and_type"
  add_index "lexical_variants", ["type"], :name => "index_lexical_variants_on_type"

  create_table "matches", :force => true do |t|
    t.integer  "concept_id"
    t.string   "type"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matches", ["concept_id", "type"], :name => "index_matches_on_concept_id_and_type"
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
