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

class User < ActiveRecord::Base
  
  ROLES = [
    "reader", "editor", "publisher", "administrator"
  ]

  validates_length_of :forename, :surname, :within => 2..255
  validates_inclusion_of :role, :in => ROLES
  validates_presence_of :email
  validates_uniqueness_of :email
  # validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  acts_as_authentic do |config|
    config.validate_email_field = false
    config.maintain_sessions = false
  end

  def self.default_role
    "reader"
  end

  def name
    "#{forename} #{surname}"
  end

  def owns_role?(name)
    self.role == name.to_s
  end

  def to_s
    self.name.to_s
  end

end