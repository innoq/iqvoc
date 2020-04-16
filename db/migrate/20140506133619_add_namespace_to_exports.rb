class AddNamespaceToExports < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :default_namespace, :string
  end
end
