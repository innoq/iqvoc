class CreateInstanceConfiguration < ActiveRecord::Migration

  def up
    create_table :instance_configuration, :force => true do |t|
      t.string :key
      t.string :value
    end
  end

  def down
    drop_table :instance_configuration
  end

end
