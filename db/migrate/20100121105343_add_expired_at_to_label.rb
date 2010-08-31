class AddExpiredAtToLabel < ActiveRecord::Migration
 def self.up
    add_column :labels, :expired_at, :date
  end

  def self.down
    remove_column :labels, :expired_at
  end
end
