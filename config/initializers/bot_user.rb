User.find_or_create_by(email: 'botuser@iqvoc') do |user|
  user.forename = 'botuser'
  user.surname = 'botuser'
  user.password = 'botuser'
  user.password_confirmation = 'botuser'
  user.role = 'match_editor'
  user.active = true
end
