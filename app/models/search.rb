class Search
  
  def self.single_query(params = {})
    type       = params[:type] || :label
    query_type = params[:query_type] || 'contains'
    
    case type.to_sym
    when :inflectional
      scope = Iqvoc::XLLabel.base_class.scoped({})
    when :label
      scope = Iqvoc::XLLabel.base_class.scoped({})
      # scope = scope.scoped :include => :labelings
      scope = scope.includes(:labelings)
      # scope = scope.scoped :conditions => "published_at IS NOT NULL"
      scope = scope.published
    when :pref_label
      scope = Iqvoc::XLLabel.base_class.scoped({})
      # scope = scope.scoped :conditions => { :labelings => { :type => 'PrefLabeling' } }, :include => :labelings
      scope = scope.includes(:labelings).where(:labelings => { :type => Iqvoc::XLLabel.pref_labeling_class_name })
      scope = scope.published
    when :note
      scope = Note::Base.scoped({})
    end
    
    case query_type  
    when 'contains'
      query_str = "%#{params[:query]}%"
      if type == "inflectional"
        scope = scope.select("DISTINCT #{Label::Base.table_name}.*")
        # FIXME: UMT-specific!
        scope = scope.joins(Inflectional::Base.name.to_relation_name)
        scope = scope.where(Inflectional::Base.arel_table[:value].matches(query_str))
      else
        scope = scope.by_query_value(query_str)
      end
      scope = scope.by_language(params[:languages].to_a)
    when 'begins_with'
      query_str = "#{params[:query]}%"
      if type == "inflectional"
        scope = scope.select("DISTINCT #{Label::Base.table_name}.*")
        # FIXME: UMT-specific!
        scope = scope.joins(Inflectional::Base.name.to_relation_name)
        scope = scope.where(Inflectional::Base.arel_table[:value].matches(query_str))
      else
        scope = scope.by_query_value(query_str)
      end
      scope = scope.by_language(params[:languages].to_a)
    when 'ends_with'
      query_str = "%#{params[:query]}"
      if type == "inflectional"
        scope = scope.select("DISTINCT #{Label::Base.table_name}.*")
        # FIXME: UMT-specific!
        scope = scope.joins(Inflectional::Base.name.to_relation_name)
        scope = scope.where(Inflectional::Base.arel_table[:value].matches(query_str))
      else
        scope = scope.by_query_value(query_str)
      end
      scope = scope.by_language(params[:languages].to_a)
    when 'regexp'
      query_str = params[:query]
      if type == "inflectional"
        scope = scope.select("DISTINCT #{Label::Base.table_name}.*")
        # FIXME: UMT-specific!
        scope = scope.joins(Inflectional::Base.name.to_relation_name)
        scope = scope.where(["#{Inflectional::Base.arel_table[:value].to_sql} REGEXP ?", query_str])
      else
        scope = scope.where(["#{Label::Base.arel_table[:value].to_sql} REGEXP ?", query_str])
      end
      scope = scope.by_language(params[:languages].to_a)
    when 'exact'
      query_str = params[:query]
      if type == "inflectional"
        scope = scope.select("DISTINCT #{Label::Base.table_name}.*")
        # FIXME: UMT-specific!
        scope = scope.joins(Inflectional::Base.name.to_relation_name)
        scope = scope.where(Inflectional::Base.arel_table[:value].eq(query_str))
      else
        scope = scope.by_query_value(query_str)
      end
      scope = scope.by_language(params[:languages].to_a)
    end
    
    if type == "inflectional"
      scope = scope.order("LOWER(#{Inflectional::Base.arel_table[:value].to_sql})")
    else
      scope = scope.order("LOWER(#{Label::Base.arel_table[:value].to_sql})")
      scope = scope.paginate(:page => params[:page], :per_page => 50)
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