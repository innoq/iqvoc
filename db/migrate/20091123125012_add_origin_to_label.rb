class AddOriginToLabel < ActiveRecord::Migration
  def self.up
    add_column :labels, :origin, :string
  end

  def self.down
    remove_column :labels, :origin
  end
end
