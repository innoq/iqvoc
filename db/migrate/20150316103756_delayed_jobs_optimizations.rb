class DelayedJobsOptimizations < ActiveRecord::Migration
  def change
    # add queue index
    add_index :delayed_jobs, [:queue], :name => 'delayed_jobs_queue'

    # add handy custom error column to store application errors
    # (e.g. response error for reverse matches creation)
    add_column :delayed_jobs, :error_message, :string

    # add columns and indicies to store referencing entities
    add_column :delayed_jobs, :delayed_reference_type, :string
    add_column :delayed_jobs, :delayed_reference_id, :integer
    add_column :delayed_jobs, :delayed_global_reference_id, :string
    add_index :delayed_jobs, [:delayed_reference_type], :name => 'delayed_jobs_delayed_reference_type'
    add_index :delayed_jobs, [:delayed_reference_id],   :name => 'delayed_jobs_delayed_reference_id'
    add_index :delayed_jobs, [:delayed_global_reference_id], :name => 'delayed_jobs_delayed_global_reference_id'
  end
end
