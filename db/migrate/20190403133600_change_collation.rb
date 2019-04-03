class ChangeCollation < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      change_database_encoding('utf8mb4', 'utf8mb4_0900_as_ci')
    end
  end

  def down
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      change_database_encoding('utf8', 'utf8mb4_general_ci')
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
