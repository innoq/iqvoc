module SearchExtension
  extend ActiveSupport::Concern
  
  def self.multi_query(params = {})
    query_terms = params[:query].split(/\r\n/)
    results     = []
    query_terms.each do |term|
      results << { :query => term, :result => single_query(params.merge({:query => term})) }
    end
    results
  end
  
  def single_query
    # TODO
  end
  
  def searchable?
    false
  end
  
  def supports_multi_query?
    false
  end
  
end
