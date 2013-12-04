class SearchResultCollection
  extend Forwardable
  def_delegators :@results, :size, :each, :[], :page, :current_page, :+, :sort

  def initialize(results)
    @results = results
  end
end
