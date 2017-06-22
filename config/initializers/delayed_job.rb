# keep failed delayed jobs
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
Delayed::Worker.max_run_time = 2.days
