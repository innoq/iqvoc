class AddFkIndexesToExportsAndImports < ActiveRecord::Migration[4.2]
  def change
    add_index :imports, :user_id
    add_index :exports, :user_id
  end
end
