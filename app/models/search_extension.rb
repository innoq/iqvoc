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
      # Implement single_query in your specific class that should be searchable!
    end
  
    def self.searchable?
      false
    end
  
    def self.supports_multi_query?
      false
    end
    
    def self.forces_multi_query?
      false
    end
    
    def self.build_query_string(params = {})
      query_type = params[:query_type] || 'contains'

      query_str = case query_type
      when 'contains'
        "%#{params[:query]}%"
      when 'begins_with'
        "#{params[:query]}%"
      when 'ends_with'
        "%#{params[:query]}"
        # when 'regexp'
        #   params[:query]
      when 'exact'
        params[:query]
      else
        params[:query]
      end
      
      query_str
    end
    
  end
  
end
