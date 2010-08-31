class AddIndexToInflectionalsValue < ActiveRecord::Migration
  def self.up
    add_index :inflectionals, :value
  end

  def self.down
    remove_index :inflectionals, :value
  end
end
