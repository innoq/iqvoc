namespace :iqvoc do
  
  namespace :users do
    desc 'Creates first test users (Administrator and Demo-User).'
    task :init => :environment do
      admin = User.create!(
        :forename => 'Admin', 
        :surname => 'Istrator', 
        :email => 'admin@iqvoc', 
        :password => 'admin', 
        :password_confirmation => 'admin',
        :active => true,
        :role => "administrator")
      user  = User.create!(
        :forename => 'Demo', 
        :surname => 'User', 
        :email => 'demo@iqvoc', 
        :password => 'cooluri', 
        :password_confirmation => 'cooluri',
        :active => true,
        :role => "reader")
    end
  
    desc 'Deletes all users.' 
    task :delete_all => :environment do
      # ist es ein guter Stil, das Löschen aller Datensätze als Nebeneffekt
      # von dem puts zu implementieren?
      puts "#{UserPreference.delete_all} preferences deleted"
      puts "#{User.delete_all} users deleted"
    end
  end
  
end
