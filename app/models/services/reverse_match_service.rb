module Services
  class ReverseMatchService
    include Rails.application.routes.url_helpers

    def initialize(host, port)
      raise ArgumentError if host.empty?
      raise ArgumentError unless port.is_a?(Integer)
      @host = host
      @port = port
    end

    def build_job(type, concept, subject, match_class)
      raise ArgumentError if type.empty? || concept.nil? || subject.empty? || match_class.empty?
      referer = root_url(host: @host, port: @port)
      object = rdf_url(concept.origin, host: @host, port: @port)
      match_classes = Iqvoc::Concept.reverse_match_class_names
      match_class = match_classes[match_class]
      ReverseMatchJob.new(type, concept, match_class, subject, object, referer)
    end

    def add(job)
      Delayed::Job.enqueue(job, queue: 'reverse_matches')
    end
  end
end
