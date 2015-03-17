namespace :iqvoc do
  namespace :matches do
    stdout_logger = Logger.new(STDOUT)
    stdout_logger.level = Logger::INFO

    desc 'Create reverse matches jobs for already known matches'
    task :create_jobs => :environment do
      raise "You have to specify the host of the current iqvoc instance. Example: rake iqvoc:matches:create_jobs HOST='http://try.iqvoc.com' PORT='80'" unless ENV['HOST']
      raise "You have to specify the host of the current iqvoc instance. Example: rake iqvoc:matches:create_jobs HOST='http://try.iqvoc.com' PORT='80'" unless ENV['PORT']

      raise "Error: there are pending reverse match jobs. Clear or process them before." if Delayed::Job.where(queue: 'reverse_matches').any?

      iqvoc_sources = Iqvoc.config['sources.iqvoc'].map { |s| URI.parse(s) }
      host = ENV['HOST']
      port = ENV['PORT'].to_i

      reverse_match_service = Services::ReverseMatchService.new(host, port)

      Match::Base.includes(:concept).find_each do |m|
        target_base_uri = base_uri(m.value)

        # create jobs if target_base_uri is in iqvoc_sources
        if iqvoc_sources.include?(target_base_uri)
          job = reverse_match_service.build_job(:add_match, m.concept, m.value, m.type)
          reverse_match_service.add(job)

          stdout_logger.info "Create #{job.match_class}-job: #{job.subject} => #{job.object}"
        else
          stdout_logger.info "#{m.value}: is not a known iQvoc source"
        end
      end
    end

    desc 'Delete all reverse matches jobs'
    task :delete_jobs => :environment do
      jobs = Delayed::Backend::ActiveRecord::Job.where(queue: 'reverse_matches')
      jobs.destroy_all
      stdout_logger.info "Cleared Jobs"
    end

    private

    def base_uri(url_string)
      target_uri = URI.parse(url_string)
      base_uri = URI.parse("#{target_uri.scheme}://#{target_uri.host}:#{target_uri.port}")
    end

  end
end
