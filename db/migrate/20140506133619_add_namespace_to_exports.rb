class AddNamespaceToExports < ActiveRecord::Migration
  def change
    add_column :exports, :default_namespace, :string
  end
end
