class CreateCompoundForms < ActiveRecord::Migration
  def self.up
    create_table :compound_forms, :force => true do |t|
      t.integer :domain_id
      t.timestamps
    end
    
    add_index :compound_forms, :domain_id
  end

  def self.down
    drop_table :compound_forms
  end
end
