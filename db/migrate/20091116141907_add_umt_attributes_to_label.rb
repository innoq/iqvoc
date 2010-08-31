class AddUmtAttributesToLabel < ActiveRecord::Migration
  def self.up
    add_column :labels, :status, :string
  end

  def self.down
    remove_column :labels, :status
  end
end
