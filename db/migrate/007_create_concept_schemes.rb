class CreateConceptSchemes < ActiveRecord::Migration
  def self.up
    create_table :concept_schemes do |t|
      t.string :uuid, :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :concept_schemes
  end
end
