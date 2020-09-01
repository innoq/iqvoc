class AddCollectionTypeIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :collection_members, :type
  end
end
