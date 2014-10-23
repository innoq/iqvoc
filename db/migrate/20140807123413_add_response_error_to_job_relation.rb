class AddResponseErrorToJobRelation < ActiveRecord::Migration
  def change
    add_column :job_relations, :response_error, :string
  end
end
