class SearchResultsController < ApplicationController
  skip_before_filter :require_user
  
  def index
    authorize! :read, Concept::Base
    
    if params[:query]
      return invalid_search(I18n.t('txt.controllers.search_results.insufficient_data')) if params[:query].blank?
      
      unless Iqvoc.searchable_class_names.include?(params[:type])
        raise "'#{params[:type]}' is not a valid / configured searchable class!"
      end
      
      @klass = params[:type].constantize
      query_size = params[:query].split(/\r\n/).size
      
      if @klass.forces_multi_query? || (@klass.supports_multi_query? && query_size > 1)
        @multi_query = true
        @results = @klass.multi_query(params)
      else
        @multi_query = false
        @results = @klass.single_query(params).paginate(:page => params[:page], :per_page => 50)
      end

    end
  end
  
  protected
  
  def invalid_search(msg=nil)
    flash[:error] = msg || I18n.t('txt.controllers.search_results.query_invalid')
    render :action => 'index', :status => 422
  end

end
