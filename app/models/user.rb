class User < AbstractUser
  ROLES = ['reader', 'editor', 'publisher', 'administrator']

  validates_inclusion_of :role, in: ROLES
  validates_length_of :forename, :surname, within: 2..255
  validates_presence_of :email
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP

  def name
    "#{forename} #{surname}"
  end

  def initials
    "#{forename[0]}#{surname[0]}"
  end
end
