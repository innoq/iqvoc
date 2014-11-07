class AddPublishedAtToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, 'published_at', :date unless column_exists? :labels, 'published_at'
  end

  def self.down
    remove_column :labels, 'published_at'
  end
end
