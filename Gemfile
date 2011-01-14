source 'http://rubygems.org'

gem 'rails', '3.0.3'

gem 'will_paginate', '3.0.pre2'
gem 'authlogic'
gem 'cancan'
gem 'iq_rdf', '~>0.0.8', :git => 'git@github.com:innoq/iq_rdf.git'
gem 'json'

# Hotfix for the problem of engine/plugin helpers not being mixed in.
# https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
# http://github.com/drogus/rails_helpers_fix
gem 'rails_helpers_fix'

platforms :jruby do
  gem 'jruby-openssl'
  gem 'jruby-jars', '1.6.0.rc1'
  gem 'warbler'
end

group :development, :production, :production_internal do
  # gem 'iqvoc_umt', :path => '../iqvoc_umt'
  gem 'iqvoc_spez', :git => 'git@github.com:innoq/iqvoc_spez.git'
  # gem 'iqvoc_spez', :path => '../iqvoc_spez'
end

group :development do
  gem 'mongrel'
  gem 'awesome_print'
end

group :development, :test do
  gem 'mysql' # AR Bug
  gem 'mysql2'
end

group :test do
  gem 'nokogiri', '1.4.3.1'
  gem 'capybara'
  # gem 'capybara-envjs'
  gem 'database_cleaner', '0.6.0.rc.3'
  gem 'launchy'    # So you can do Then show me the page
  gem 'factory_girl_rails'
end

group :production, :production_internal do
  platforms :ruby do
    gem 'sqlite3-ruby', :require => 'sqlite3'
  end
  
  platforms :jruby do
    gem 'activerecord-oracle_enhanced-adapter'
  end
end
