# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'iqvoc/version'

Gem::Specification.new do |s|
  s.name        = "iqvoc"
  s.version     = Iqvoc::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Glaser", "Till Schulte-Coerne", "Frederik Dohr"]
  s.email       = ["robert.glaser@innoq.com", "till.schulte-coerne@innoq.com", "frederik.dohr@innoq.com"]
  s.homepage    = "http://github.com/innoq/iqvoc"
  s.summary     = "iQvoc"
  s.description = "iQvoc - a SKOS(-XL) vocabulary management system built on the Semantic Web"

  s.add_dependency 'rails', '~> 3.1.3'
  s.add_dependency 'bundler'
  s.add_dependency 'kaminari'
  s.add_dependency 'authlogic'
  s.add_dependency 'cancan'
  s.add_dependency 'iq_rdf', '~> 0.1.0'
  s.add_dependency 'json'
  s.add_dependency 'rails_autolink'

  s.files = %w(LICENSE README.md CHANGELOG.md Gemfile Gemfile.lock Rakefile iqvoc.gemspec) + 
    Dir.glob("{app,config,db,public,lib,test,vendor}/**/*")
  s.test_files = Dir.glob("{test}/**/*")
  s.executables = Dir.glob("{bin}/**/*")
  s.require_paths = ["lib"]
end
