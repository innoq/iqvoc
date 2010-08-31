namespace :app do
  
  task :bootstrap => :environment do
    puts "Creating basic users..."
    Rake::Task["users:init"].invoke
    
    puts "Finished bootstrapping. You can now login with admin@iqvoc / admin and manage users."
  end
  
end