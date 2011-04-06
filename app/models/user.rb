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