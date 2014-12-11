class ReverseMatchJob < Struct.new(:type, :match_class, :subject, :object, :referer, :origin)
  def enqueue(job)
    JobRelation.create(owner_reference: self.origin, job: job)
  end

  def perform
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
      raise e unless e.response[:status] == 409
    end

  end

  def error(job, exception)
    error_type = nil

    case exception
    when Faraday::Error::ConnectionFailed
      error_type = 'connection_failed'
    when Faraday::Error::TimeoutError
      error_type = 'timeout_error'
    when Faraday::Error::ResourceNotFound
      error_type = 'resource_not_found'
    when Faraday::ClientError
      body = exception.response[:body] || {}
      message = JSON.parse(body) unless body.empty?
      error_type = message['type']
    end

    unless error_type.nil?
      reference = JobRelation.find_by(owner_reference: self.origin, job: job)
      reference.update_attribute(:response_error, error_type)
    end
  end

  def success(job)
    reference = JobRelation.find_by(owner_reference: self.origin, job: job)
    reference.delete
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
