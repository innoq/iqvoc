class CreateJobRelations < ActiveRecord::Migration
  def change
    create_table :job_relations do |t|
      t.string :type
      t.string :owner_reference
      t.string :job_id

      t.timestamps
    end
  end
end
