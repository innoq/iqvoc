class AddIndexOnLabelingsTargetId < ActiveRecord::Migration[8.1]
  def change
    add_index :labelings, :target_id
  end
end
