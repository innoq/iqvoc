class RenameIsActiveInUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, :is_active, :active
  end

  def self.down
    rename_column :users, :active, :is_active
  end
end
