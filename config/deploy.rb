# bundler bootstrap
require 'bundler/capistrano'

# main details
capistrano_history = {}
capistrano_history = YAML::load(File.open(".capistrano_history.yml")) if File.exist?(".capistrano_history.yml")

set :application, "iqvoc"
servername = Capistrano::CLI.ui.ask("Please enter the IP or Hostname of the ec2 instance to deploy to [#{capistrano_history['last_servername']}]: ")
servername = capistrano_history['last_servername'] if servername == ""
capistrano_history['last_servername'] = servername
role :web, servername
role :app, servername
role :db,  servername, :primary => true

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to, "/var/www/default"
set :deploy_via, :remote_cache
set :user, "passenger"
set :use_sudo, false

# repo details
set :scm, :git
# set :scm_username, "passenger"
set :repository, "git@github.com:innoq/iqvoc.git"
capistrano_history['last_branch'] = "master" if capistrano_history['last_branch'].nil? || capistrano_history['last_branch'] == ""
set :branch, Capistrano::CLI.ui.ask("Please enter the branch or tag we should use [#{capistrano_history['last_branch']}]: ")
set :branch, capistrano_history['last_branch'] if fetch(:branch) == ""
capistrano_history['last_branch'] = fetch(:branch)
set :git_enable_submodules, 1

File.open(".capistrano_history.yml", 'w') { |f|
  f.write(capistrano_history.to_yaml)
}

# tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink shared resources on each release"
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
