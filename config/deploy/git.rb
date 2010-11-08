@capistrano_history ||= {}

# repo details
set :scm, :git
set :git_enable_submodules, 1
# set :scm_username, "passenger"
set :repository, "git@github.com:innoq/iqvoc.git"
@capistrano_history['last_branch'] = "master" if @capistrano_history['last_branch'].nil? || @capistrano_history['last_branch'] == ""
set :branch, Capistrano::CLI.ui.ask("Please enter the branch or tag we should use [#{@capistrano_history['last_branch']}]: ")
set :branch, @capistrano_history['last_branch'] if fetch(:branch) == ""
@capistrano_history['last_branch'] = fetch(:branch)