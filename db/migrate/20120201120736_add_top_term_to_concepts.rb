class AddTopTermToConcepts < ActiveRecord::Migration[4.2]
  def change
    add_column :concepts, :top_term, :boolean, default: false
  end
end
