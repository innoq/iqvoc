class AddZipToExports < ActiveRecord::Migration[8.1]
  def change
    add_column :exports, :zip, :boolean, default: false, null: false
  end
end
