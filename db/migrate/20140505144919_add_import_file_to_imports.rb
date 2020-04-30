class AddImportFileToImports < ActiveRecord::Migration[4.2]
  def change
    add_column :imports, :import_file, :string
  end
end
