class ChangeCollation < ActiveRecord::Migration
  MYSQL_COLLATION_SUPPORT_VERSION = 8

  def up
    change_database_encoding('utf8mb4', 'utf8mb4_0900_as_ci') if check_supporting_mysql_version
  end

  def down
    change_database_encoding('utf8', 'utf8mb4_general_ci') if check_supporting_mysql_version
  end

  private
  def check_supporting_mysql_version
    connection = ActiveRecord::Base.connection
    if connection.adapter_name == 'Mysql2'
      version_row = connection.select_rows("SHOW VARIABLES WHERE variable_name = 'version'").try(:first)
      raise "There is a problem of our code with your MySQL version, please report in GitHub Repository" if version_row.first != "version"
      version_row.last.first.to_i >= MYSQL_COLLATION_SUPPORT_VERSION
    else
      false
    end
  end

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
