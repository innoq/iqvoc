class ExtendNotesValueFieldLength < ActiveRecord::Migration
  def self.up
    change_column :notes, :value, :string, limit: 4000
  end

  def self.down
  end
end
