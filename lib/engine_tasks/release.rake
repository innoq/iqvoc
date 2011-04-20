#!/usr/bin/env ruby
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

    desc "Migrate the database through scripts in db/migrate and update db/schema.rb by invoking db:schema:dump. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
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
          puts "Branch must be one of #{branches.join(', ')}"
        end

        `git clone -b #{branch} #{fetch_url} #{path}`

        FileUtils.cd(path) do

          if (File.exist?('Gemfile.production'))
            FileUtils.mv('Gemfile.production', 'Gemfile')
            if File.exist?('Gemfile.lock')
              FileUtils.rm('Gemfile.lock')
              puts `unset BUNDLE_GEMFILE && unset RUBYOPT && bundle install --path=vendor/bundle`
            end
          end

          puts `unset BUNDLE_GEMFILE && unset RUBYOPT && bundle install --deployment`

          puts `unset BUNDLE_GEMFILE && unset RUBYOPT && bundle exec rake iqvoc:assets:copy`

        end

        `zip -qr #{path}.zip #{path}`

        puts "Release complete: #{path}.zip"

      ensure
        # FileUtils.rm_rf('tmp/release')
      end

    end
  end
end