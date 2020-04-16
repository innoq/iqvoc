class ExtendNotesValueFieldLength < ActiveRecord::Migration[4.2]
  def self.up
    change_column :notes, :value, :string, limit: 4000
  end

  def self.down
  end
end
