class SearchResult
  extend Forwardable
  def_delegators :@result_object, :build_search_result_rdf, :owner, :target,
      :value, :label, :rdf_namespace, :rdf_predicate

  def initialize(result_object)
    @result_object = result_object
  end

  def model_name
    @result_object.class.model_name
  end

  def search_result_partial_name
    @result_object.class.search_result_partial_name
  end

  def language
    if @result_object.is_a?(Labeling::Base)
      @result_object.target.try(:language)
    else
      @result_object.try(:language)
    end
  end

  def to_s
    if @result_object.is_a?(Labeling::Base)
      @result_object.target.value
    else
      @result_object.try(:owner).try(:pref_label).to_s
    end
  end
end
