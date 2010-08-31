class CreateCompoundFormContents < ActiveRecord::Migration
  def self.up
    create_table :compound_form_contents, :force => true do |t|
      t.integer :compound_form_id
      t.integer :label_id
      t.integer :order
      t.timestamps
    end
    
    add_index :compound_form_contents, [:compound_form_id, :label_id]
  end

  def self.down
    drop_table :compound_form_contents
  end
end
