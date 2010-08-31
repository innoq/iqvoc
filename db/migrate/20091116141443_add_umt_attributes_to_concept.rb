class AddUmtAttributesToConcept < ActiveRecord::Migration
  def self.up
    add_column :concepts, :status, :string
    add_column :concepts, :classified, :string
  end

  def self.down
    remove_column :concepts, :classified
    remove_column :concepts, :status
  end
end
