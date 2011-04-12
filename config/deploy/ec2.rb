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

@capistrano_history ||= {}

# main details
servername = Capistrano::CLI.ui.ask("Please enter the IP or Hostname of the ec2 instance to deploy to [#{@capistrano_history['last_servername']}]: ")
servername = @capistrano_history['last_servername'] if servername == ""
@capistrano_history['last_servername'] = servername
role :web, servername
role :app, servername
role :db,  servername, :primary => true

keyfile = 'doesnt_exist'
while !File.exist?(File.expand_path(keyfile))
  keyfile = Capistrano::CLI.ui.ask("Please enter the file holding the ssh key for user 'passenger'  [#{@capistrano_history['last_keyfile']}]: ")
  keyfile = @capistrano_history['last_keyfile'] if keyfile == ""
  @capistrano_history['last_keyfile'] = keyfile
end
ssh_options[:keys] = [File.expand_path(keyfile)]

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to, "/var/www/default"
set :deploy_via, :remote_cache
set :user, "passenger"
set :use_sudo, false

save_history if defined?(save_history)