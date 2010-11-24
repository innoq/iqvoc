class Label::SKOS::Base < Label::Base

  after_initialize :publish

  def publish
    self.published_at = Time.now
  end

  # ********** Methods

  def self.single_query(params = {})
    query_str = build_query_string(params)

    by_query_value(query_str).
      by_language(params[:languages].to_a).
      published.
      order("LOWER(#{Label::Base.table_name}.value)")
  end

  def self.search_result_partial_name
    'partials/label/skos/search_result'
  end

end
