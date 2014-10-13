class ChangeValueInNotes < ActiveRecord::Migration
  def self.up
    change_column :notes, :value, :string, length: 4000
  end

  def self.down
  end
end
