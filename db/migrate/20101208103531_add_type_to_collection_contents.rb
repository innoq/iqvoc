class AddTypeToCollectionContents < ActiveRecord::Migration
  def self.up
    rename_column :collection_members, :concept_id, :target_id
    add_column :collection_members, :type, :string
    Collection::Member::Base.update_all(:type => 'Collection::Member::Concept')
    Collection::Base.update_all(:type => 'Collection::Base')
  end

  def self.down
  end
end
