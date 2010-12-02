class SearchResultsController < ApplicationController
  skip_before_filter :require_user
  
  def index
    authorize! :read, Concept::Base

    @available_languages = (Iqvoc.available_languages + Iqvoc::Concept.labeling_class_names.values.flatten).uniq.each_with_object({}) do |lang_sym, hsh|
      lang_sym ||= "none"
      hsh[lang_sym.to_s] = t("languages.#{lang_sym.to_s}", :default => lang_sym.to_s)
    end

    # Query param tricks
    params[:type] ||= params[:t]
    params[:query] ||= params[:q]
    params[:languages] ||= params[:l]
    params[:query_type] ||= params[:qt]
    request.query_parameters.delete("commit")
    request.query_parameters.delete("utf8")

    if params[:query]
      return invalid_search(I18n.t('txt.controllers.search_results.insufficient_data')) if params[:query].blank?

      params[:languages] << nil if params[:languages].is_a?(Array) and params[:languages].include?("none")
      
      unless type_class_index = Iqvoc.searchable_class_names.map(&:parameterize).index(params[:type].parameterize)
        raise "'#{params[:type]}' is not a valid / configured searchable class! Must be one of " + Iqvoc.searchable_class_names.join(', ')
      end
      
      @klass = Iqvoc.searchable_class_names[type_class_index].constantize
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
