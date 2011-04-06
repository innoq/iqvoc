class AddCollectionTables < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
    end
    
    create_table :collection_contents do |t|
      t.integer :collection_id
      t.integer :concept_id
    end
  end

  def self.down
  end
end
