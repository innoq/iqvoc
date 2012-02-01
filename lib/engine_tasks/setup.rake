namespace :iqvoc do
  namespace :setup do
    desc "Generate secret token initializer"
    task :generate_secret_token do
      require 'iqvoc'

      Iqvoc.generate_secret_token
    end
  end
end
