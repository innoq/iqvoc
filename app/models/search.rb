class Search
  
  def self.single_query(params = {})
    type       = params[:type] || :label
    query_type = params[:query_type] || 'contains'
    
    case type.to_sym
    when :inflectional
      scope = Label.scoped({})
    when :label
      scope = Label.scoped({})
      scope = scope.scoped :include => :labelings
      scope = scope.scoped :conditions => "published_at IS NOT NULL"
    when :pref_label
      scope = Label.scoped({})
      scope = scope.scoped :conditions => { :labelings => { :type => 'PrefLabeling' } }, :include => :labelings
      scope = scope.scoped :conditions => "published_at IS NOT NULL"
    when :note
      scope = Note.scoped({})
      # Die polymorphe Assoziation owner kann nicht per Eager Loading mitgeladen werden.
    end
    
    case query_type  
    when 'contains'
      if type == "inflectional"
        scope = scope.scoped :select => "DISTINCT labels.*"
        scope = scope.scoped :joins => :inflectionals, 
                             :conditions => ["inflectionals.value LIKE ? AND labels.language IN (?)", "%#{params[:query]}%", params[:languages]]
      else
        scope = scope.scoped :conditions => ['value LIKE ? AND language IN (?)', "%#{params[:query]}%", params[:languages]]
      end
    when 'begins_with'
      if type == "inflectional"
        scope = scope.scoped :select => "DISTINCT labels.*"
        scope = scope.scoped :joins => :inflectionals, 
                             :conditions => ['inflectionals.value LIKE ? AND labels.language IN (?)', "#{params[:query]}%", params[:languages]]
      else
        scope = scope.scoped :conditions => ['value LIKE ? AND language IN (?)', "#{params[:query]}%", params[:languages]]
      end
    when 'ends_with'
      if type == "inflectional"
        scope = scope.scoped :select => "DISTINCT labels.*"
        scope = scope.scoped :joins => :inflectionals, 
                             :conditions => ['inflectionals.value LIKE ? AND labels.language IN (?)', "%#{params[:query]}", params[:languages]]
      else
        scope = scope.scoped :conditions => ['value LIKE ? AND language IN (?)', "%#{params[:query]}", params[:languages]]
      end
    when 'regexp'
      if type == "inflectional"
        scope = scope.scoped :select => "DISTINCT labels.*"
        scope = scope.scoped :joins => :inflectionals, 
                             :conditions => ['inflectionals.value REGEXP ? AND labels.language IN (?)', "%#{params[:query]}%", params[:languages]]
      else
        scope = scope.scoped :conditions => ['value REGEXP ? AND language IN (?)', "%#{params[:query]}%", params[:languages]]
      end
    when 'exact'
      if type == "inflectional"
        scope = scope.scoped :select => "DISTINCT labels.*"
        scope = scope.scoped :joins => :inflectionals, 
                             :conditions => ['inflectionals.value = ? AND labels.language IN (?)', params[:query], params[:languages]]
      else
        scope = scope.scoped :conditions => ['value = ? AND language IN (?)', params[:query], params[:languages]]
      end
    end
    
    if type == "inflectional"
      scope = scope.scoped :order => 'LOWER(inflectionals.value)'
    else
      scope = scope.scoped :order => 'LOWER(value)'
      scope = scope.paginate :page => params[:page], :per_page => 50
    end
    
    scope
  end
  
  def self.multi_query(params = {})
    query_terms = params[:query].split(/\r\n/)
    results     = []
    query_terms.each do |term|
      results << { :query => term, :result => single_query(params.merge({:query => term})) }
    end
    results
  end
  
end