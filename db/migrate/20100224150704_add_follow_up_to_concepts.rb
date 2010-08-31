class AddFollowUpToConcepts < ActiveRecord::Migration
  def self.up
    add_column :concepts, :follow_up, :date
  end

  def self.down
    remove_column :concepts, :follow_up
  end
end
