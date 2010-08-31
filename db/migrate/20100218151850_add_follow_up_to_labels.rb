class AddFollowUpToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :follow_up, :date
  end

  def self.down
    remove_column :labels, :follow_up
  end
end
