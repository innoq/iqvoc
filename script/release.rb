require 'rubygems'
require 'fileutils'
require 'active_support/core_ext'
require 'lib/iqvoc/version'

FileUtils.rm_rf('tmp/release') if File.directory?('tmp/release')
FileUtils.mkdir 'tmp/release'
begin
  FileUtils.cd('tmp/release')  do
    git_remotes = `git remote show origin`
    raise "Couldn't read Fetch URL from #{git_remotes}" unless git_remotes =~ /Fetch URL: (.+)$/
    fetch_url = $1

    raise "Couldn't read remote branches from #{git_remotes}" unless git_remotes =~ /^\s*Remote branches:\n((\s*\w+(\s+\w*)?\n)+)/
    branches = $1.split(/\n/).map do |line|
      line.gsub(/^\s*(\w+)(\s+\w*)?$/) { $1 }
    end

    branch = nil
    while true
      STDOUT.print "Enter branch name [#{branches.first}]: "
      branch = (STDIN.gets.presence || branches.first).gsub(/\n/, "")
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