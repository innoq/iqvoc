class DropJobRelation < ActiveRecord::Migration[4.2]
  def change
    drop_table :job_relations
  end
end
