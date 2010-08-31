class CreateClassifications < ActiveRecord::Migration
  def self.up
    create_table :classifications, :force => true do |t|
      t.integer :owner_id
      t.integer :target_id
      t.timestamps
    end
    
    add_index :classifications, [:owner_id, :target_id]
  end

  def self.down
    drop_table :classifications
  end
end
