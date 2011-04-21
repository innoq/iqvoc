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

namespace :iqvoc do
  namespace :release do

    desc "Build a production ready release to tmp/release. Use the parameter RUBY_CMD to speficy weather to use ruby or jruby to bundle the release."
    task :build => :environment do

      path = Rails.root.join('tmp/release')

      FileUtils.rm_rf(path) if File.directory?(path)
      FileUtils.mkdir path
      begin
        git_remotes = `git remote show origin`
        raise "Couldn't read Fetch URL from #{git_remotes}" unless git_remotes.match(/Fetch URL: (.+)$/)
        fetch_url = $1

        git_remote_branches = `git branch -r`
        raise "Couldn't read remote branches from #{git_remote_branches}" unless git_remote_branches.match(/origin\/.+/)

        git_remote_branches.match(/(origin\/.+)\n/m)
        branches = $1.squish.gsub("origin/", "").split(" ")

        branch = nil
        while true
          STDOUT.print "Enter branch name [master]: "
          branch = (STDIN.gets.presence || 'master').gsub(/\n/, "")
          break if branches.include?(branch)
          puts "Branch must be one of #{branches.inspect}"
        end

        `git clone -b #{branch} #{fetch_url} #{path}`
        `rm -rf #{File.join(path, ".git")}`

        ruby_cmd = if ENV['RUBY_CMD']
          "#{ENV['RUBY_CMD']} -S"
        else
          RUBY_PLATFORM == 'java' ? "jruby -S" : "ruby -S"
        end
        gemfile = File.join(path, "Gemfile")

        Bundler.with_clean_env do 
          FileUtils.cd(path) do

            if (File.exist?('Gemfile.production'))
              FileUtils.mv('Gemfile.production', 'Gemfile')
              if File.exist?('Gemfile.lock')
                FileUtils.rm('Gemfile.lock')
                
                puts `#{ruby_cmd} bundle install --path=vendor/bundle --gemfile=#{gemfile}`
              end
            end

            puts `#{ruby_cmd} bundle install --deployment --gemfile=#{gemfile}`

            puts `#{ruby_cmd} bundle --gemfile=#{gemfile} exec rake iqvoc:assets:copy`

          end
        end
        
        puts "Release complete: #{path}"

      ensure

      end

    end
  end
end