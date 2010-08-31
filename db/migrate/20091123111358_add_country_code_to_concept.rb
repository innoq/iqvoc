class AddCountryCodeToConcept < ActiveRecord::Migration
  def self.up
    add_column :concepts, :country_code, :string, :limit => 4
  end

  def self.down
    remove_column :concepts, :country_code
  end
end
