class AddFkIndexesToExportsAndImports < ActiveRecord::Migration
  def change
    add_index :imports, :user_id
    add_index :exports, :user_id
  end
end
