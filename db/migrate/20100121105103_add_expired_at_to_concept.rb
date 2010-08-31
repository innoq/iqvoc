class AddExpiredAtToConcept < ActiveRecord::Migration
  def self.up
    add_column :concepts, :expired_at, :date
  end

  def self.down
    remove_column :concepts, :expired_at
  end
end
