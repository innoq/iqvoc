class RemoveDefaultForOwnerTypeInNotes < ActiveRecord::Migration
  def self.up
    change_column_default :notes, :owner_type, nil
  end

  def self.down
    change_column_default :notes, :owner_type, "Concept"
  end
end
