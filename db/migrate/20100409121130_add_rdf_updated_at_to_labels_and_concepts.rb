class AddRdfUpdatedAtToLabelsAndConcepts < ActiveRecord::Migration
  def self.up
    add_column :concepts, :rdf_updated_at, :date
    add_column :labels, :rdf_updated_at, :date
  end

  def self.down
    remove_column :concepts, :rdf_updated_at
    remove_column :labels, :rdf_updated_at
  end
end
