namespace :release do
  desc 'Builds a new .gem release'
  task :build => :environment do
    system 'rm iqvoc-*.gem'
    system 'gem build iqvoc.gemspec'
  end

  desc 'Builds, tags and pushes a new release to Rubygems'
  task :push => :environment do
    Rake::Task['release:build'].invoke
    system %(git tag `grep VERSION lib/iqvoc/version.rb | sed -e 's/.*= /v/' -e 's/"//g'`)
    system 'git push --tags'
    system 'gem push iqvoc-*.gem'
  end
end
