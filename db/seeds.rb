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
