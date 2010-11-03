source 'http://rubygems.org'

gem 'rails', '3.0.1'

gem 'will_paginate', '3.0.pre2'
gem 'authlogic'
gem 'cancan'
gem 'iq_rdf', '~>0.0.8'
gem 'warbler'

# Hotfix for the problem of engine/plugin helpers not being mixed in.
# https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
# http://github.com/drogus/rails_helpers_fix
gem 'rails_helpers_fix'

#gem 'iqvoc_spez', :path => '../iqvoc_spez' # :git => 'git@github.com:innoq/iqvoc_umt.git'
gem 'iqvoc_spez', :git => 'git@github.com:innoq/iqvoc_spez.git'

group :development do
  gem 'mongrel'
  gem 'ruby-debug'
  gem 'awesome_print', :require => 'ap'
end

group :test, :cucumber do
  gem 'capybara'
  # gem 'capybara-envjs'
  # gem 'culerity'
  gem 'database_cleaner', '0.6.0.rc.3'
  # gem 'cucumber-rails'
  # gem 'cucumber'
  # gem 'spork'
  gem 'launchy'    # So you can do Then show me the page
  gem 'factory_girl_rails'
end

group :production do
  platforms :ruby do
    gem 'sqlite3-ruby', :require => 'sqlite3'
  end
end

platforms :mri do
  gem 'mysql' # AR Bug
  gem 'mysql2'
end

platforms :jruby do
  gem 'activerecord-jdbcmysql-adapter'
end
