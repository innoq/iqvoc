class AddNotations < ActiveRecord::Migration[4.2]
  def change
    create_table :notations do |t|
      t.integer 'concept_id'
      t.string 'value', limit: 4000
      t.string 'data_type', limit: 4000
    end
  end
end
