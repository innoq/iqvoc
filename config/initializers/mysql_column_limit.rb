require 'active_record/connection_adapters/abstract_mysql_adapter'

# Hack to set max varchar column size to 191 instead of 255.
# This is necessary to use mysql's utf8mb4 encoding and use
# full unicode support
module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter
      if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
        NATIVE_DATABASE_TYPES[:string] = { :name => "varchar", :limit => 191 }
      end
    end
  end
end