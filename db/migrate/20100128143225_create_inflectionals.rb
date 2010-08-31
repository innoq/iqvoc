class CreateInflectionals < ActiveRecord::Migration
  def self.up
    create_table :inflectionals do |t|
      t.references :label
      t.string :value

      t.timestamps
    end
    
    add_index :inflectionals, :label_id
  end

  def self.down
    drop_table :inflectionals
  end
end
