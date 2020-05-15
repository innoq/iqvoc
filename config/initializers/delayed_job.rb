# keep failed delayed jobs
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 2.days
