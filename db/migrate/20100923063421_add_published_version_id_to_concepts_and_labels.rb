class AddPublishedVersionIdToConceptsAndLabels < ActiveRecord::Migration
  def self.up
    add_column :concepts, :published_version_id, :integer
    add_column :labels, :published_version_id, :integer
  end

  def self.down
    remove_column :concepts, :published_version_id
    remove_column :labels, :published_version_id
  end
end
