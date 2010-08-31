module SearchResultsHelper
  def highlight_query(text, query, multi_query)
    if multi_query
      text
    else
      # call to ActiveSupport's highlight
      highlight(text, query)
    end
  end
end
