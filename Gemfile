source 'http://rubygems.org'

gem 'rails', '3.0.0'

gem 'will_paginate', '3.0.pre2'
gem 'authlogic'
gem 'cancan'
gem 'iq_rdf'

group :development do
  gem 'mongrel'
end

group :test, :cucumber do
  gem 'capybara'
  # gem 'capybara-envjs'
  gem 'culerity'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber'
 # gem 'spork'
  gem 'launchy'    # So you can do Then show me the page
  gem 'factory_girl_rails'
end

platforms :mri do
  gem 'mysql2'
end

platforms :jruby do
  gem 'activerecord-jdbcmysql-adapter'
  gem 'warbler'
  gem 'jruby-jars', '1.4.0'
end
