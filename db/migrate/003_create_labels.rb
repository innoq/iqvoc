class CreateLabels < ActiveRecord::Migration
  def self.up
    create_table :labels do |t|
#       t.string  :uuid,     :limit => 36,  :null => false
      t.string  :type,     :limit => 36,  :null => false
      t.belongs_to :owner
      t.timestamps
    end
  end

  def self.down
    drop_table :labels
  end
end
