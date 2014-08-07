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
      match_classes = Iqvoc::Concept.reverse_match_class_names
      match_class = match_classes[match_class]
      ReverseMatchJob.new(type, match_class, subject, object, referer, origin)
    end

    def add(job)
      Delayed::Job.enqueue(job, queue: 'reverse_matches')
    end

    def remove(job)
      Delayed::Job.enqueue(job, queue: 'reverse_matches')
    end
  end
end
