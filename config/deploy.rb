# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "#{File.dirname(__FILE__)}/deploy/history"
load_history

load "#{File.dirname(__FILE__)}/deploy/common.rb"

set :default_stage, "innoq"
set :stages, %w(ec2 innoq bian)
require 'capistrano/ext/multistage'

# RVM bootstrap
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.2'
# set :rvm_type, :user

# bundler bootstrap
require 'bundler/capistrano'

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
    run "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
