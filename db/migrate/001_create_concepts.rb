class CreateConcepts < ActiveRecord::Migration
  def self.up
    create_table :concepts do |t|
      t.string :uuid, :limit => 36
      t.string :type, :limit => 50, :null => false, :default => 'Concept'

      t.timestamps
    end
  end

  def self.down
    drop_table :concepts
  end
end
