class Utf8mb4Conversion < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      change_column :note_annotations, :value, :string, limit: 191
      change_database_encoding('utf8mb4', 'utf8mb4_general_ci')
    end
  end

  private

  def change_database_encoding(encoding, collation)
    connection = ActiveRecord::Base.connection
    database = connection.current_database
    tables = connection.tables

    execute <<-SQL
      ALTER DATABASE #{database} CHARACTER SET #{encoding} COLLATE #{collation};
      SQL

    tables.each do |table|
      execute <<-SQL
        ALTER TABLE #{database}.#{table} CONVERT TO CHARACTER SET #{encoding} COLLATE #{collation};
        SQL
    end
  end
end
