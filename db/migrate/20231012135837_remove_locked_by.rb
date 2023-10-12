class RemoveLockedBy < ActiveRecord::Migration[7.0]

  def change
    remove_column :concepts, :locked_by
  end
end
