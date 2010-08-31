class AddToReviewToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :to_review, :boolean
  end

  def self.down
    remove_column :labels, :to_review
  end
end
