class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      t.references :concept
      t.string :type
      t.string :value

      t.timestamps
    end
    
    add_index :matches, :concept_id
  end

  def self.down
    drop_table :matches
  end
end
