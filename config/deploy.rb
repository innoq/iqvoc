require "#{File.dirname(__FILE__)}/deploy/history"
load_history

set :invokeable_task_prefix, "iqvoc"

load "#{File.dirname(__FILE__)}/deploy/common.rb"

set :default_stage, "ec2"
set :stages, %w(ec2)
require 'capistrano/ext/multistage'

vendor = Capistrano::CLI.ui.ask("Please enter the vendor for your iQvoc instance [#{@capistrano_history['last_vendor']}]: ")
vendor = @capistrano_history['last_vendor'] if vendor == ""
@capistrano_history['last_vendor'] = vendor
set :vendor, vendor

# RVM bootstrap
$:.unshift(File.expand_path("~/.rvm/lib"))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.8.7-p302'
set :rvm_type, :user

# bundler bootstrap
require 'bundler/capistrano'
# turn off --deployment flag. We need to rely on vendor specific Gemfiles without according .lock files.
set :bundle_flags, "--quiet"

# main details
set :application, "iqvoc"

# repo details
set :scm, :git
set :git_enable_submodules, 1
# set :scm_username, "passenger"
set :repository, "git@github.com:innoq/iqvoc.git"
@capistrano_history['last_branch'] = "master" if @capistrano_history['last_branch'].nil? || @capistrano_history['last_branch'] == ""
set :branch, Capistrano::CLI.ui.ask("Please enter the branch or tag we should use [#{@capistrano_history['last_branch']}]: ")
set :branch, @capistrano_history['last_branch'] if fetch(:branch) == ""
@capistrano_history['last_branch'] = fetch(:branch)

save_history

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

before 'bundle:install', 'deploy:copy_gemfile'
after 'deploy:update_code', 'deploy:symlink_shared'
