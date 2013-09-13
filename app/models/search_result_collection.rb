class SearchResultCollection
  extend Forwardable
  def_delegators :@results, :size, :each, :[]

  attr_reader :adaptor

  def initialize(adaptor, results)
    @adaptor = adaptor
    @results = results
  end
end
