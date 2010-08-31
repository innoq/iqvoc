class CreateLabelRelations < ActiveRecord::Migration
  def self.up
    create_table :label_relations do |t|
      t.integer :domain_id
      t.integer :range_id

      t.timestamps
    end
  end

  def self.down
    drop_table :label_relations
  end
end
