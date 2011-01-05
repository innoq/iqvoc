require 'rubygems'
require 'fileutils'
require 'active_support/core_ext'
require 'lib/iqvoc/version'

FileUtils.rm_rf('tmp/release') if File.directory?('tmp/release')
FileUtils.mkdir 'tmp/release'
begin
  FileUtils.cd('tmp/release')  do
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

    `git clone -b #{branch} #{fetch_url} iqvoc`

    FileUtils.cd('iqvoc') do
      system "jruby -S bundle install --deployment --without=development test"
    end

    `tar -czf iqvoc_#{Iqvoc::VERSION}.tgz iqvoc`

  end
ensure
  # FileUtils.rm_rf('tmp/release')
end