class AddToReviewToConcepts < ActiveRecord::Migration
  def self.up
    add_column :concepts, :to_review, :boolean
  end

  def self.down
    remove_column :concepts, :to_review
  end
end
