class AddLabelings < ActiveRecord::Migration
  def self.up
    create_table :labelings, :force => true do |t|
      t.integer :owner_id
      t.integer :target_id
      t.string :owner_type
      t.string :target_type
      t.string :type
      t.timestamps
    end
    
    add_index :labelings, [:owner_id, :target_id]
  end

  def self.down
    drop_table :labelings
  end
end
