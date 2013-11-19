module DatasetInitialization
  extend ActiveSupport::Concern

  def init_datasets
    # TODO: rename sources to datasets throughout
    datasets = Iqvoc.config['sources.iqvoc'].reject {|s| s.blank? }
    datasets.map do |url|
      Dataset::IqvocDataset.new(url)
    end
  end
end
