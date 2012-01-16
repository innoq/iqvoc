namespace :iqvoc do
  namespace :setup do
    task :generate_secret_token do
      require 'iqvoc'

      Iqvoc.generate_secret_token
    end
  end
end
