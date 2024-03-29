class ReverseMatchJob < Struct.new(:type, :concept,  :match_class, :subject, :object, :referer)
  def enqueue(job)
    job.delayed_reference_id   = concept.id
    job.delayed_reference_type = concept.class.to_s
    job.delayed_global_reference_id = concept.to_global_id
    job.save!
  end

  def perform
    if concept.unpublished?
      raise MatchedConceptUnpublished, "concept_not_published_yet"
    end

    conn = connection(subject, { accept: 'application/json' })
    response = conn.get
    link = response.body['links'].detect { |h| h['rel'] == type.to_s }
    request_url = link['href']
    request_method = link['method']

    conn = connection(request_url, { content_type: 'application/json', referer: referer })

    begin
      response = conn.send(request_method) do |req|
        req.params['match_class'] = match_class
        req.params['uri'] = object
      end
    rescue Faraday::ClientError => e
      # do not catch Mapping-Exists errors, just keep job running and do nothing
      # except delete job
      if e.response.nil? || e.response[:status] != 409
        raise e
      end
    end

  end

  def error(job, exception)
    error_type = nil

    case exception
    when Faraday::ConnectionFailed
      if exception&.wrapped_exception.class == Net::OpenTimeout
        error_type = 'timeout_error'
      else
        error_type = 'connection_failed'
      end
    when Faraday::TimeoutError
      error_type = 'timeout_error'
    when Faraday::ResourceNotFound
      error_type = 'resource_not_found'
    when Faraday::ClientError
      body = exception.response[:body] || {}
      message = JSON.parse(body) unless body.empty?
      error_type = message['type']
    else
      error_type = exception.message
    end

    unless error_type.nil?
      job.error_message = error_type
      job.save!
    end
  end

  private

  def connection(url, headers = {})
    Faraday::Connection.new(url: url, headers: headers) do |builder|
      builder.use FaradayMiddleware::ParseJson
      builder.use FaradayMiddleware::FollowRedirects, limit: 5
      builder.use Faraday::Response::RaiseError
      builder.adapter Faraday.default_adapter
    end
  end
end
