class AddTopTermToConcepts < ActiveRecord::Migration

  def change
    add_column :concepts, :top_term, :boolean, default: false
  end

end
