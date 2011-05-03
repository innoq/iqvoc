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

    desc "Build a production ready release to tmp/release (or to RELEASE_PATH). Use the parameter RUBY_CMD to speficy weather to use ruby or jruby to bundle the release."
    task :build => :environment do
      ENV['RELEASE_PATH'] ||= Rails.root.join('tmp/release')
      ENV['RUBY_CMD'] ||= RUBY_PLATFORM == 'java' ? "jruby" : "ruby"

      Rake::Task["iqvoc:release:initialize"].invoke
      Rake::Task["iqvoc:release:bundle"].invoke
      Rake::Task["iqvoc:release:iqvoc_assets"].invoke
      Rake::Task["iqvoc:release:finalize"].invoke
      puts "Release complete: #{ENV['RELEASE_PATH']}"
    end

    task :initialize do
      path = File.expand_path(ENV['RELEASE_PATH'] || raise("You have to specify RELEASE_PATH"))

      FileUtils.rm_rf(path) if File.directory?(path)
      FileUtils.mkdir path

      git_remotes = `git remote show origin`
      raise "Couldn't read Fetch URL from #{git_remotes}" unless git_remotes.match(/Fetch URL: (.+)$/)
      fetch_url = $1

      git_remote_branches = `git branch -r`
      raise "Couldn't read remote branches from #{git_remote_branches}" unless git_remote_branches.match(/origin\/.+/)
      git_remote_branches.match(/(origin\/.+)\n/m)
      branches = $1.squish.gsub("origin/", "").split(" ")

      git_heroku_remote = `git remote -v`.split(/\n/).select{|s| s =~ /^heroku/}.map{|s| s.squish.split(" ").second}.first
      puts "Found heroku remote '#{git_heroku_remote}'" if git_heroku_remote

      branch = nil
      while true
        STDOUT.print "Enter branch name [master]: "
        branch = (STDIN.gets.presence || 'master').gsub(/\n/, "")
        break if branches.include?(branch)
        puts "Branch must be one of #{branches.inspect}"
      end

      `git clone -b #{branch} #{fetch_url} #{path}`

      FileUtils.cd(path) do

        # Defuse the git repository
        `git remote rm origin` # Nobody should push this back into our holy repository
        `git remote add heroku #{git_heroku_remote}` if git_heroku_remote

      end

    end

    task :bundle do
      path = File.expand_path(ENV['RELEASE_PATH'] || raise("You have to specify RELEASE_PATH"))
      gemfile = File.join(path, "Gemfile")
      ruby_cmd = ENV['RUBY_CMD'].presence || raise("You have to specify RUBY_CMD")

      Bundler.with_clean_env do
        FileUtils.cd(path) do
          
          if (File.exist?('Gemfile.production'))
            FileUtils.cp('Gemfile.production', 'Gemfile')      

            FileUtils.rm('Gemfile.lock') if File.exist?('Gemfile.lock')

            # We'll have to "rebundle" the Gemfile.lock
            puts "Gemfile was replaced by Gemfile.production. Rebundling Gemfile.lock..."
            puts `#{ruby_cmd} -S bundle install --path=vendor/bundle --gemfile=#{gemfile} --without=development:test`
          end

          puts `#{ruby_cmd} -S bundle install --deployment --gemfile=#{gemfile}`
        end
      end
    end

    task :iqvoc_assets do
      path = File.expand_path(ENV['RELEASE_PATH'] || raise("You have to specify RELEASE_PATH"))
      gemfile = File.join(path, "Gemfile")
      ruby_cmd = ENV['RUBY_CMD'].presence || raise("You have to specify RUBY_CMD")

      Bundler.with_clean_env do
        FileUtils.cd(path) do

          puts `export BUNDLE_GEMFILE='#{gemfile}' && #{ruby_cmd} -S bundle exec rake iqvoc:assets:copy`

        end
      end
    end

    task :finalize do
      path = File.expand_path(ENV['RELEASE_PATH'] || raise("You have to specify RELEASE_PATH"))

      FileUtils.cd(path) do
        `git add *`
        `git commit -m 'iqvoc:release:build: Packed release'`
      end

    end

  end
end
