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

class AbstractUser < ApplicationRecord
  self.table_name = 'users'

  delegate :can?, :cannot?, :to => :ability

  validates :email, uniqueness: { case_sensitive: false }

  validates :password,
            confirmation: {if: :require_password?},
            length: {
              minimum: 8,
              if: :require_password?
            }

  validates :password_confirmation,
            length: {
              minimum: 8,
              if: :require_password?
            }

  acts_as_authentic do |config|
    config.log_in_after_create = false
    config.log_in_after_password_change = false
    config.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512]
    config.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  def self.default_user_role
    'reader'
  end

  def name
    "#{forename} #{surname}"
  end

  def to_s
    self.name.to_s
  end

  def owns_role?(name)
    self.role == name.to_s
  end

  def ability
    @ability ||= Ability.new(self)
  end
end
