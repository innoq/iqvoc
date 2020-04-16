class AddIndexesToNotations < ActiveRecord::Migration[4.2]
  def change
    add_index :notations, :concept_id
  end
end
