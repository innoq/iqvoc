class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.string :language, :limit => 2, :default => 'en'
      t.string :value,    :limit => 1024
      t.string :type,     :limit => 50
      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
