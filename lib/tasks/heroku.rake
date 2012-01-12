namespace :heroku do
  task :config do
    HEROKU_CONFIG = %W(
      HEROKU=true
      SECRET_TOKEN=#{ActiveSupport::SecureRandom.hex(64)}
    )
    
    system "heroku config:add #{HEROKU_CONFIG.join(' ')}"
  end
end
