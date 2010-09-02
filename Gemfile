source 'http://rubygems.org'

gem 'rails', '3.0.0'

gem 'will_paginate', '3.0.pre2'
gem 'authlogic'
gem 'cancan'
gem 'iq_rdf'

group :development do
  gem 'mongrel'
  
  platforms :mri do
    gem 'mysql2'
  end
  
  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
  end
end

group :test, :cucumber do
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'culerity'
end
