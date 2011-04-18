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

namespace :iqvoc do
  
  namespace :users do
    desc 'Creates first test users (Administrator and Demo-User).'
    task :init => :environment do
      if User.where(:email => 'admin@iqvoc').none?
        User.create!(
        :forename => 'Admin', 
        :surname => 'Istrator', 
        :email => 'admin@iqvoc', 
        :password => 'admin', 
        :password_confirmation => 'admin',
        :active => true,
        :role => "administrator")
      end

      if User.where(:email => 'demo@iqvoc').none?
        User.create!(
        :forename => 'Demo', 
        :surname => 'User', 
        :email => 'demo@iqvoc', 
        :password => 'cooluri', 
        :password_confirmation => 'cooluri',
        :active => true,
        :role => "reader")
      end
    end
  
    desc 'Deletes all users.' 
    task :delete_all => :environment do
      puts "#{User.delete_all} users deleted"
    end
  end
  
end
