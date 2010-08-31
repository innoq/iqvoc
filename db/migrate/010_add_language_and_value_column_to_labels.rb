class AddLanguageAndValueColumnToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :language, :string, :limit => 2, :null => false, :default => 'en'
    add_column :labels, :value, :string, :limit => 1024, :null => true
  end

  def self.down
    remove_column :labels, :language
    remove_column :labels, :value
  end
end
