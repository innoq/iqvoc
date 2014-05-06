class AddImportFileToImports < ActiveRecord::Migration
  def change
    add_column :imports, :import_file, :string
  end
end
