class AddTelephoneNumberToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :telephone_number, :string
  end

  def self.down
    remove_column :users, :telephone_number
  end
end
