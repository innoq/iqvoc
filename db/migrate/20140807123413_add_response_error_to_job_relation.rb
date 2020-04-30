class AddResponseErrorToJobRelation < ActiveRecord::Migration[4.2]
  def change
    add_column :job_relations, :response_error, :string
  end
end
