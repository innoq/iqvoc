module SearchResultsHelper
  def highlight_query(text, query, multi_query)
    if multi_query
      raw text.to_s
    else
      # call to ActiveSupport's highlight
      raw highlight(text.to_s, query)
    end
  end
end
