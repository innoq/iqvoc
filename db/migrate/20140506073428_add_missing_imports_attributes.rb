class AddMissingImportsAttributes < ActiveRecord::Migration
  def change
    add_column :imports, :publish, :boolean
    add_column :imports, :default_namespace, :string
  end
end
