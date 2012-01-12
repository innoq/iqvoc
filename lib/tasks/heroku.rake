namespace :heroku do
  task :config do
    require 'securerandom'
    
    HEROKU_CONFIG = %W(
      HEROKU=true
      SECRET_TOKEN=#{SecureRandom.hex(64)}
    )
    
    system "heroku config:add #{HEROKU_CONFIG.join(' ')}"
  end
end
