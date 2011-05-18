class RemoveClassificationsAndClassifiers < ActiveRecord::Migration

  def self.up
    drop_table "classifications"
    drop_table "classifiers"

  end

  def self.down

    create_table "classifications", :force => true do |t|
      t.integer  "owner_id"
      t.integer  "target_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "classifications", ["owner_id", "target_id"], :name => "ix_classifications_fk"

    create_table "classifiers", :force => true do |t|
      t.string   "title"
      t.string   "description"
      t.string   "notation"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "classifiers", ["notation"], :name => "ix_classifiers_on_notation"

  end

end
