class AddIndexesToNotations < ActiveRecord::Migration
  def change
    add_index :notations, :concept_id
  end
end
