class CreateCollectionLabels < ActiveRecord::Migration
  def self.up
    create_table :collection_labels, :force => true do |t|
      t.references :collection
      t.string :value
      t.string :language
      t.timestamps
    end
    
    add_index :collection_labels, :collection_id, :name => 'ix_collection_labels_fk'
  end

  def self.down
    drop_table :collection_labels
  end
end