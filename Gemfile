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

source 'https://rubygems.org'

# TODO: The following dependencies could be included by the "gemspec" command.
# There is only one problem: gemspec puts the dependencies automatically to a
# group (:development by default). This is not what we need.
gem 'rails', '4.1.0'
gem 'protected_attributes', '>= 1.0.7'
gem 'kaminari'
gem 'kaminari-bootstrap', '~> 3.0.1'
gem 'authlogic', '~> 3.4.0'
gem 'cancan'
gem 'iq_rdf', '>= 0.1.13'
gem 'iq_triplestorage'
gem 'json'
gem 'rails_autolink'
gem 'jruby-openssl', :platforms => :jruby
gem 'faraday'
gem 'nokogiri', '~> 1.6.0'
gem 'linkeddata'
gem 'uglifier'
gem 'sass-rails', '~> 4.0.3'
gem 'bootstrap-sass', '~> 3.1.1.0'
gem 'bootstrap_form', '~> 2.1.0'
gem 'font-awesome-rails'
gem 'apipie-rails'
gem 'maruku', :require => false
gem 'database_cleaner'
gem 'delayed_job_active_record', '~> 4.0.1'

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
    gem 'pry-rails'
    gem 'hirb-unicode'
    gem 'cane'
  end

  gem 'pry-byebug', '~> 1.1.2', :platforms => :ruby_20

  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'capybara-webkit'
  gem 'factory_girl_rails'
  # gem 'turn'
  gem 'webmock'
end

group :production do
end

group :heroku do
  gem 'pg', :platforms => :ruby
end
