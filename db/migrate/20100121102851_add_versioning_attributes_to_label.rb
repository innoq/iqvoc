class AddVersioningAttributesToLabel < ActiveRecord::Migration
 def self.up
    add_column :labels, :rev, :integer, :default => 1
    add_column :labels, :published_at, :date
    add_column :labels, :locked_by, :integer
  end

  def self.down
    remove_column :labels, :rev
    remove_column :labels, :published_at
    remove_column :labels, :locked_by
  end
end
