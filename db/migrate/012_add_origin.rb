class AddOrigin < ActiveRecord::Migration
  def self.up
    add_column :concepts, :origin, :string
  end

  def self.down
    remove_column :concepts, :origin
  end
end
