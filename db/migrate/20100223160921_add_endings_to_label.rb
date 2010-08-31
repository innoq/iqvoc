class AddEndingsToLabel < ActiveRecord::Migration
  def self.up
    add_column :labels, :endings, :string
  end

  def self.down
    remove_column :labels, :endings
  end
end
