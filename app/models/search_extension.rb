module SearchExtension
  extend ActiveSupport::Concern
  
  included do
    def self.multi_query(params = {})
      query_terms = params[:query].split(/\r\n/)
      results     = []
      query_terms.each do |term|
        results << { :query => term, :result => single_query(params.merge({:query => term})) }
      end
      results
    end
  
    def self.single_query(params = {})
      # TODO
    end
  
    def self.searchable?
      false
    end
  
    def self.supports_multi_query?
      false
    end
  end
  
end
