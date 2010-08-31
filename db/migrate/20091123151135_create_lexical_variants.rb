class CreateLexicalVariants < ActiveRecord::Migration
  def self.up
    create_table :lexical_variants, :force => true do |t|
      t.integer :owner_id
      t.string :type
      t.string :language, :limit => 2
      t.string :value
      t.timestamps
    end
    
    add_index :lexical_variants, :owner_id
  end

  def self.down
    drop_table :lexical_variants
  end
end
