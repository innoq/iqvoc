class DropJobRelation < ActiveRecord::Migration
  def change
    drop_table :job_relations
  end
end
