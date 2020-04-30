class AddPublishedAtToLabels < ActiveRecord::Migration[4.2]
  def self.up
    add_column :labels, 'published_at', :date unless column_exists? :labels, 'published_at'
  end

  def self.down
    remove_column :labels, 'published_at'
  end
end
