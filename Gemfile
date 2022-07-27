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
gem 'rails', '~> 6.1.5', '>= 6.1.5.1'
gem 'puma', '< 6.0'
gem 'kaminari'
gem 'authlogic'
gem 'scrypt'
gem 'cancancan'
gem 'iq_rdf'
gem 'iq_triplestorage'
gem 'json'
gem 'rails_autolink'
gem 'faraday'
gem 'faraday_middleware'
gem 'nokogiri'
gem 'linkeddata'
gem 'rdf-vocab'
gem "deep_cloneable"
gem "bootstrap_form", "~> 4.0"
gem 'apipie-rails'
gem 'maruku', require: false
gem 'database_cleaner', '~> 1.8.5'
gem 'delayed_job_active_record'
gem 'carrierwave'
gem 'daemons'
gem 'faucet_pipeline_rails'

gem 'bootsnap', '>= 1.4.4', require: false

# database adapters
# comment out those you do don't need or use a different Gemfile
#gem  'mysql2', '~> 0.4.0'
#gem 'sqlite3'
gem 'pg'

gem 'rack-mini-profiler'

group :development do
  gem 'better_errors'
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
end

group :development, :test do
  gem 'pry-rails', require: 'pry'
end

group :test do
  gem 'capybara'
  gem 'cuprite'
  gem 'webmock'
end

group :production do
end

group :heroku do
  gem 'rails_12factor'
end
