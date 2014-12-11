module ReverseMatchErrors
  extend ActiveSupport::Concern

  private

  def messages
    {
      mapping_added:    { status: 200, json: { type: 'mapping_added', message: 'Concept mapping created.'} },
      mapping_removed:  { status: 200, json: { type: 'mapping_removed', message: 'Concept mapping removed.'} },
      mapping_exists:   { status: 200, json: { type: 'mapping_exists', message: 'Concept mapping exists.'} },
      parameter_missing:{ status: 400, json: { type: 'parameter_missing', message: 'Required parameter missing.'} },
      unknown_relation: { status: 400, json: { type: 'unknown_relation', message: 'Concept or relation is wrong.'} },
      unknown_match:    { status: 400, json: { type: 'unknown_match', message: 'Unknown match class.' } },
      no_referer:       { status: 400, json: { type: 'no_referer', message: 'Referer is not set.' } },
      unknown_referer:  { status: 403, json: { type: 'unknown_referer', message: 'Unknown referer.' } },
      in_processing:    { status: 403, json: { type: 'in_processing', message: 'Concept in processing' } },
      server_error:     { status: 500, json: {} }
    }
  end

  def status_and_body(key)
    [messages[key][:status], messages[key][:json]]
  end
end
