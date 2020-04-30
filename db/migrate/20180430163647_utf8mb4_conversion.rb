class Utf8mb4Conversion < ActiveRecord::Migration[4.2]

  def up
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      change_column :collection_members, :type, :string, limit: 191
      change_column :concept_relations, :type, :string, limit: 191
      change_column :concepts, :type, :string, limit: 191

      change_column :configuration_settings, :key, :string, limit: 191
      change_column :configuration_settings, :value, :string, limit: 191

      change_column :delayed_jobs, :locked_by, :string, limit: 191
      change_column :delayed_jobs, :queue, :string, limit: 191
      change_column :delayed_jobs, :error_message, :string, limit: 191
      change_column :delayed_jobs, :delayed_reference_type, :string, limit: 191
      change_column :delayed_jobs, :delayed_global_reference_id, :string, limit: 191

      change_column :exports, :token, :string, limit: 191
      change_column :exports, :default_namespace, :string, limit: 191

      change_column :imports, :import_file, :string, limit: 191
      change_column :imports, :default_namespace, :string, limit: 191

      change_column :labelings, :type, :string, limit: 191

      change_column :labels, :type, :string, limit: 191
      change_column :labels, :language, :string, limit: 191

      change_column :matches, :type, :string, limit: 191
      change_column :matches, :value, :string, limit: 191

      change_column :note_annotations, :value, :string, limit: 191
      change_column :note_annotations, :language, :string, limit: 191

      change_column :notes, :owner_type, :string, limit: 191

      change_column :schema_migrations, :version, :string, limit: 191

      change_column :users, :forename, :string, limit: 191
      change_column :users, :surname, :string, limit: 191
      change_column :users, :email, :string, limit: 191
      change_column :users, :crypted_password, :string, limit: 191
      change_column :users, :password_salt, :string, limit: 191
      change_column :users, :persistence_token, :string, limit: 191
      change_column :users, :perishable_token, :string, limit: 191
      change_column :users, :role, :string, limit: 191
      change_column :users, :telephone_number, :string, limit: 191
      change_column :users, :type, :string, limit: 191

      change_database_encoding('utf8mb4', 'utf8mb4_general_ci')
    end
  end

  def down
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      change_database_encoding('utf8', 'utf8_general_ci')

      change_column :collection_members, :type, :string, limit: 255
      change_column :concept_relations, :type, :string, limit: 255
      change_column :concepts, :type, :string, limit: 255

      change_column :configuration_settings, :key, :string, limit: 255
      change_column :configuration_settings, :value, :string, limit: 255

      change_column :delayed_jobs, :locked_by, :string, limit: 255
      change_column :delayed_jobs, :queue, :string, limit: 255
      change_column :delayed_jobs, :error_message, :string, limit: 255
      change_column :delayed_jobs, :delayed_reference_type, :string, limit: 255
      change_column :delayed_jobs, :delayed_global_reference_id, :string, limit: 255

      change_column :exports, :token, :string, limit: 255
      change_column :exports, :default_namespace, :string, limit: 255

      change_column :imports, :import_file, :string, limit: 255
      change_column :imports, :default_namespace, :string, limit: 255

      change_column :labelings, :type, :string, limit: 255

      change_column :labels, :type, :string, limit: 255
      change_column :labels, :language, :string, limit: 255

      change_column :matches, :type, :string, limit: 255
      change_column :matches, :value, :string, limit: 255

      change_column :note_annotations, :value, :string, limit: 255
      change_column :note_annotations, :language, :string, limit: 255

      change_column :notes, :owner_type, :string, limit: 255

      change_column :schema_migrations, :version, :string, limit: 255

      change_column :users, :forename, :string, limit: 255
      change_column :users, :surname, :string, limit: 255
      change_column :users, :email, :string, limit: 255
      change_column :users, :crypted_password, :string, limit: 255
      change_column :users, :password_salt, :string, limit: 255
      change_column :users, :persistence_token, :string, limit: 255
      change_column :users, :perishable_token, :string, limit: 255
      change_column :users, :role, :string, limit: 255
      change_column :users, :telephone_number, :string, limit: 255
      change_column :users, :type, :string, limit: 255
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
