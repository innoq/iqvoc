class ChangeOriginLengths < ActiveRecord::Migration
  def self.up
    change_column :concepts, :origin, :string, :limit => 4000
    change_column :labels, :origin, :string, :limit => 4000
  end

  def self.down
    change_column :concepts, :origin, :string, :limit => 255
    change_column :labels, :origin, :string, :limit => 255
  end
end