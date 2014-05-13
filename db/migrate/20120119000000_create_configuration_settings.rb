class CreateConfigurationSettings < ActiveRecord::Migration

  def up
    create_table :configuration_settings, force: true do |t|
      t.string :key
      t.string :value
    end
  end

  def down
    drop_table :configuration_settings
  end

end
