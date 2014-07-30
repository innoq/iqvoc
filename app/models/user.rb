class User < AbstractUser
  ROLES = [ 'reader', 'editor', 'publisher', 'administrator' ]
  validates_inclusion_of :role, in: ROLES
  validates_length_of :forename, :surname, within: 2..255
end
