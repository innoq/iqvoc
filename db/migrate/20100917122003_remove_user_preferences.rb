class RemoveUserPreferences < ActiveRecord::Migration
  def self.up
    drop_table :user_preferences
  end

  def self.down
  end
end
