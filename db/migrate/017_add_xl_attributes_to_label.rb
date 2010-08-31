class AddXlAttributesToLabel < ActiveRecord::Migration
  def self.up
    add_column :labels, :base_form, :string
    add_column :labels, :inflectional_code, :string
    add_column :labels, :part_of_speech, :string
  end

  def self.down
    remove_column :labels, :base_form
    remove_column :labels, :inflectional_code
    remove_column :labels, :part_of_speech
  end
end