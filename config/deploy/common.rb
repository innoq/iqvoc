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

desc "Runs a rake task on the remote system. Use TASK'<taskname + parameters>' to specify the task."
task :invoke_task do
  prefix = fetch(:invokeable_task_prefix, "")
  if ENV['TASK'] and ENV['TASK'] =~ /^#{prefix}/
    run("cd #{deploy_to}/current; rake --trace #{ENV['TASK']} RAILS_ENV=production")
  else
    run("cd #{deploy_to}/current; rake -T #{prefix} --trace RAILS_ENV=production")
  end
end

desc "Tail production log files"
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

namespace :deploy do

  desc "Copy you current config/database.yml to the server"
  task :database_config_copy, :roles => :app do
    file_name = File.expand_path("config/database.yml")
    raise "File not found: #{file_name}" unless File.exist?(file_name)
    run "mkdir -p #{shared_path}/config/"
    put File.open(file_name).read, "#{shared_path}/config/database.yml"
  end

  desc "Create default sqlite3 config/database.yml"
  task :database_config_sqlite3, :roles => :app do
    config = {
      'production' => {
        "adapter" => "sqlite3",
        "database" => "#{shared_path}/db/production.sqlite3",
        "pool" => 5,
        "timeout" => 5000,
      }
    }
    run "mkdir -p #{shared_path}/config/"
    run "mkdir -p #{shared_path}/db/"
    put config.to_yaml, "#{shared_path}/config/database.yml"
  end
  
  desc "Copy vendor specific Gemfile"
  task :copy_gemfile, :roles => :app do
    run "cp #{release_path}/Gemfile.#{vendor}_demo #{release_path}/Gemfile"
  end
end
