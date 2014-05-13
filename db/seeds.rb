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

if User.where(email: 'admin@iqvoc').none?
  User.create! do |user|
    user.forename = 'Admin'
    user.surname  = 'Istrator'
    user.email    = 'admin@iqvoc'
    user.password = 'admin'
    user.password_confirmation = 'admin'
    user.active = true
    user.role = "administrator"
  end
end

if User.where(email: 'demo@iqvoc').none?
  User.create! do |user|
    user.forename = 'Demo'
    user.surname  = 'User'
    user.email    = 'demo@iqvoc'
    user.password = 'cooluri'
    user.password_confirmation = 'cooluri'
    user.active = true
    user.role = "reader"
  end
end
