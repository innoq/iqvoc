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

# Be sure to restart your server when you modify this file.

if Iqvoc.const_defined?(:Application)
  
  if ENV['HEROKU']
    puts 'heroku app detected; using session secret from config vars...'
    Rails.application.config.secret_token = ENV['SECRET_TOKEN']
  elsif !File.exists?(Rails.root.join('config', 'initializers', 'secret_token.rb'))
    system "bundle exec rake setup:generate_secret_token"
    require Rails.root.join('config', 'initializers', 'secret_token.rb')
  end
  
end
