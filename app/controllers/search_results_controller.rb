class SearchResultsController < ApplicationController
  skip_before_filter :require_user
  
  def index
    authorize! :read, Concept::Base
    
    if params[:query]
      return invalid_search(I18n.t('txt.controllers.search_results.insufficient_data')) if params[:query].blank?
      
      query_size = params[:query].split(/\r\n/).size
      
      if params[:type] == "inflectional"
        @multi_query = true
        @results = Search.multi_query(params)
      elsif query_size == 1 && params[:type] != "inflectional"
        @multi_query = false
        @results = Search.single_query(params)
      elsif query_size > 1 && params[:type] != "inflectional"
        @multi_query = true
        @results = Search.multi_query(params)
      end

    end
  end
  
  protected
  
  def invalid_search(msg=nil)
    flash[:error] = msg || I18n.t('txt.controllers.search_results.query_invalid')
    render :action => 'index', :status => 422
  end

end
