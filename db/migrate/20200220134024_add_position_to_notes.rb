class AddPositionToNotes < ActiveRecord::Migration[4.2]
  def change
    add_column :notes, :position, :integer
  end
end
