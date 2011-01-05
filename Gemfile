source 'http://rubygems.org'

gem 'rails', '3.0.3'

gem 'will_paginate', '3.0.pre2'
gem 'authlogic'
gem 'cancan'
gem 'iq_rdf', '~>0.0.8', :git => 'git@github.com:innoq/iq_rdf.git'
gem 'warbler'
gem 'activerecord-oracle_enhanced-adapter'

# Hotfix for the problem of engine/plugin helpers not being mixed in.
# https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
# http://github.com/drogus/rails_helpers_fix
gem 'rails_helpers_fix'

group :development, :production  do
  # gem 'iqvoc_umt', :path => '../iqvoc_umt'
  gem 'iqvoc_spez', :git => 'git@github.com:innoq/iqvoc_spez.git'
  # gem 'iqvoc_spez', :path => '../iqvoc_spez'
end

group :development do
  gem 'mongrel'
  gem 'ruby-debug'
  gem 'awesome_print', :require => 'ap'
  
  platforms :ruby do
    gem 'mysql' # AR Bug
    gem 'mysql2'
  end

  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
  end
end

group :test do
  gem 'nokogiri', '1.4.3.1'
  gem 'capybara'
  # gem 'capybara-envjs'
  gem 'database_cleaner', '0.6.0.rc.3'
  gem 'launchy'    # So you can do Then show me the page
  gem 'factory_girl_rails'
end

group :production do
  platforms :ruby do
    gem 'sqlite3-ruby', :require => 'sqlite3'
  end
end
