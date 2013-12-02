class SearchResultCollection
  extend Forwardable
  def_delegators :@results, :size, :each, :[]

  attr_reader :dataset

  def initialize(dataset, results)
    @dataset = dataset
    @results = results
  end
end
