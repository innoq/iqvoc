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
gem 'rails', '~> 5.1.0'
gem 'puma', '~> 3.0'
gem 'kaminari'
gem 'kaminari-bootstrap'
gem 'authlogic', '~> 3.8.0'
gem 'cancancan', '~> 1.17.0'
gem 'iq_rdf', '>= 0.1.16'
gem 'iq_triplestorage'
gem 'json'
gem 'rails_autolink'
gem 'faraday', '0.9.0'
gem 'faraday_middleware'
gem 'nokogiri'
gem 'linkeddata'
gem "rdf-vocab"
gem "deep_cloneable"
gem 'uglifier'
gem 'sass-rails', '~> 5.0.0'
gem 'bootstrap_form', '~> 2.7.0'
gem 'font-awesome-rails'
gem 'apipie-rails'
gem 'maruku', require: false
gem 'database_cleaner'
gem 'delayed_job_active_record'
gem 'carrierwave'
gem 'autoprefixer-rails', '~> 6.5.1.1'
gem 'daemons'

# database adapters
# comment out those you do don't need or use a different Gemfile
#gem  'mysql2', '~> 0.4.0'
#gem 'sqlite3'
gem 'pg'

group :development do
  gem 'better_errors'
  gem 'web-console'
  gem 'listen'
end

group :development, :test do
  gem 'pry-rails', require: 'pry'
  gem 'rack-mini-profiler'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'webmock'
  gem 'simplecov'
  gem 'minitest', '5.10.3' # remove after update to rails v5.2
end

group :production do
  gem 'activerecord-nulldb-adapter'
  #version updates must be done in the Dockerfile as well
  gem 'passenger', '= 5.3.7'
end

platforms :ruby do
  gem 'therubyracer'
end

group :heroku do
  gem 'rails_12factor'
end
