module Services
  class ReverseMatchService
    include Rails.application.routes.url_helpers

    def initialize(host, port)
      @host = host
      @port = port
    end

    def build_job(type, origin, subject, match_class)
      referer = root_url(host: @host, port: @port)
      object = rdf_url(origin, host: @host, port: @port)

      ReverseMatchJob.new(type, match_class, subject, object, referer)
    end

    def add(job)
      Delayed::Job.enqueue(job, queue: 'reverse_matches')
    end

    def remove(job)
      Delayed::Job.enqueue(job, queue: 'reverse_matches')
    end
  end
end
