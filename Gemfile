# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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
gem 'rails', '3.2.13'

group :assets do
  gem 'uglifier',   '>= 1.0.3'
  gem 'sass-rails', '~> 3.2.5'
  gem 'bootstrap-sass', '2.3.1.3'
  gem 'therubyracer', :platforms => :ruby
end

gem 'kaminari', '0.13.0'
gem 'authlogic'
gem 'cancan'
gem 'iq_rdf'
gem 'iq_triplestorage'
gem 'json'
gem 'rails_autolink'
gem 'jruby-openssl', :platforms => :jruby
gem 'simple_form'

group :development do
  gem 'view_marker'
  gem 'better_errors'
  gem 'binding_of_caller', :platform => :ruby
  gem 'quiet_assets'
end

group :development, :test do
  gem 'awesome_print'

  platforms :ruby do
    gem 'mysql2', '0.3.13'
    gem 'sqlite3'

    gem 'zeus'
    gem 'pry'
    gem 'pry-rails'
    gem 'pry-debugger'
    gem 'pry-remote'
    gem 'hirb-unicode'
    gem 'cane'
  end

  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

group :test do
  gem 'nokogiri'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'turn'
  gem 'webmock'
end

group :production do
end

group :heroku do
  gem 'pg', :platforms => :ruby
  gem 'passenger'
end
