# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "iqvoc/version"

Gem::Specification.new do |s|
  s.name        = "iqvoc"
  s.version     = Iqvoc::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Glaser", "Till Schulte-Coerne"]
  s.email       = ["robert.glaser@innoq.com", "till.schulte-coerne@innoq.com"]
  s.homepage    = "http://innoq.com"
  s.summary     = "iQvoc"
  s.description = ""
  
  s.add_dependency "rails", '3.0.5'
  s.add_dependency "bundler"
  s.add_dependency 'will_paginate', '3.0.pre2'
  s.add_dependency 'authlogic'
  s.add_dependency 'cancan'
  s.add_dependency 'iq_rdf', '~> 0.0.14'
  s.add_dependency 'json'

  s.files = %w(LICENSE README.md Gemfile Gemfile.lock Rakefile iqvoc_skosxl.gemspec) + Dir.glob("{app,config,public,lib,test}/**/*")
  s.test_files = Dir.glob("{test}/**/*")
  s.executables = Dir.glob("{bin}/**/*")
  s.require_paths = ["lib"]
end
