module DatasetInitialization
  extend ActiveSupport::Concern

  def init_datasets
    datasets = Iqvoc.config['sources.iqvoc'].reject {|s| s.blank? }
    datasets.map do |url|
      Dataset::IqvocDataset.new(url)
    end
  end

  def datasets_as_json
    init_datasets.inject({}) do |memo, dataset|
      memo[dataset.url.to_s] = dataset.name
      memo
    end.to_json
  end
end
