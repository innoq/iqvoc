class AddVersioningAttributesToConcept < ActiveRecord::Migration
  def self.up
    add_column :concepts, :rev, :integer, :default => 1
    add_column :concepts, :published_at, :date
    add_column :concepts, :locked_by, :integer
  end

  def self.down
    remove_column :concepts, :rev
    remove_column :concepts, :published_at
    remove_column :concepts, :locked_by
  end
end
