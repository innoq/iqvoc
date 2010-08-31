class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :forename
      t.string :surname
      t.string :email
      t.string :password_hash
      t.boolean :is_active

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
