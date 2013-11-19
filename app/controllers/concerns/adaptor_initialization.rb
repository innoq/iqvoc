module AdaptorInitialization
  extend ActiveSupport::Concern

  def init_adaptors(adaptor_klass)
    sources = Iqvoc.config['sources.iqvoc'].reject {|s| s.blank? }
    sources.map do |url|
      adaptor = adaptor_klass.new(url)
    end
  end
end
