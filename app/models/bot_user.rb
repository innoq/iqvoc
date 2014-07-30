class BotUser < AbstractUser
  
  ROLES = [ 'match_editor' ]
  validates_inclusion_of :role, in: ROLES

  def self.instance
    first_or_create(email: 'botuser@iqvoc',
             password: 'botuser',
             password_confirmation: 'botuser',
             role: 'match_editor',
             active: true
    )
  end

  def self.create(attributes = nil, &block)
    raise TypeError, 'Botuser already exist' if first
    super
  end

  def self.create!(attributes = nil, &block)
    raise TypeError, 'Botuser already exist' if first
    super
  end
end
