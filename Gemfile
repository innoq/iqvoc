# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source 'http://rubygems.org'

# TODO: The following dependencies could be included by the "gemspec" command.
# There is only one problem: gemspec puts the dependencies automatically to a
# group (:development by default). This is not what we need.
gem 'rails', '3.2.1'

group :assets do
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer', :platforms => :ruby
end

gem 'kaminari'
gem 'authlogic'
gem 'cancan'
gem 'iq_rdf', '~> 0.1.2'
gem 'json'
gem 'rails_autolink'
gem 'jruby-openssl', :platforms => :jruby

group :development do
  gem 'heroku'
  gem 'view_marker'
end

group :development, :test do
  gem 'awesome_print'
  
  platforms :ruby do
    gem 'mysql2'
    gem 'sqlite3'
    # v0.9 required for spork-testunit
    gem 'spork', '~> 0.9.0.rc'
    # head required for Ruby 1.9.3 compatibility; cf. https://github.com/sporkrb/spork-testunit/pull/17
    gem 'spork-testunit', :git => 'git://github.com/sporkrb/spork-testunit.git'
  end

  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

group :test do
  gem 'nokogiri', '~> 1.5.0'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'memory_test_fix'
  gem 'turn'
end

group :production do
  gem 'sqlite3', :platforms => :ruby
  gem 'activerecord-oracle_enhanced-adapter', :platforms => :jruby
end

group :heroku do
  gem 'pg', :platforms => :ruby
end
