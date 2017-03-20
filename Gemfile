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
gem 'rails', '~> 4.2.8'
gem 'kaminari'
gem 'kaminari-bootstrap', '~> 3.0.1'
gem 'authlogic', '~> 3.4.2'
gem 'cancancan', '~> 1.10.0'
gem 'iq_rdf', '>= 0.1.15'
gem 'iq_triplestorage'
gem 'json'
gem 'rails_autolink'
gem 'faraday', '0.9.0'
gem 'faraday_middleware'
gem 'nokogiri', '~> 1.6.0'
gem 'linkeddata', '~> 1.1.2'
gem 'uglifier'
gem 'sass-rails', '~> 5.0.0'
gem 'bootstrap_form', '~> 2.2.0'
gem 'font-awesome-rails', '~> 4.3.0'
gem 'apipie-rails', '~> 0.3.5'
gem 'maruku', require: false
gem 'database_cleaner'
gem 'delayed_job_active_record', '~> 4.1.1'
gem 'carrierwave'
gem 'autoprefixer-rails', '~> 6.5.1.1'

# database adapters
# comment out those you do don't need or use a different Gemfile
gem 'mysql2', '~> 0.3.13'
gem 'sqlite3'
gem 'pg'

group :development do
  gem 'view_marker'
end

group :development, :test do
  gem 'awesome_print'

  gem 'web-console'
  gem 'binding_of_caller', '0.7.3.pre1'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-byebug', '~> 1.1.2', platforms: :ruby_20
  gem 'quiet_assets'

  platforms :ruby do
    gem 'hirb-unicode'
    gem 'cane'
  end

  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.13'
  end
end

group :test do
  gem 'capybara', '~> 2.4.0'
  gem 'poltergeist', '~> 1.6.0'
  gem 'webmock'
  gem 'simplecov'
end

group :production do
end

group :heroku do
  gem 'rails_12factor'
end
