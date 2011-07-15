# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'iqvoc/version'

Gem::Specification.new do |s|
  s.name        = "iqvoc"
  s.version     = Iqvoc::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Glaser", "Till Schulte-Coerne", "Frederik Dohr"]
  s.email       = ["robert.glaser@innoq.com", "till.schulte-coerne@innoq.com"]
  s.homepage    = "http://innoq.com"
  s.summary     = "iQvoc"
  s.description = "iQvoc - a SKOS(-XL) vocabulary management system built on the Semantic Web"

  s.add_dependency 'rails', '3.0.9'
  s.add_dependency 'bundler'
  s.add_dependency 'kaminari'
  s.add_dependency 'authlogic'
  s.add_dependency 'cancan'
  s.add_dependency 'iq_rdf', '~> 0.0.14'
  s.add_dependency 'json'

  s.files = %w(LICENSE README.md Gemfile Gemfile.lock Rakefile iqvoc.gemspec) + Dir.glob("{app,config,db,public,lib,test}/**/*")
  s.test_files = Dir.glob("{test}/**/*")
  s.executables = Dir.glob("{bin}/**/*")
  s.require_paths = ["lib"]
end
