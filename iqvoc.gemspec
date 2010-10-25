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
  
  s.add_dependency "activerecord"
  s.add_dependency "rails"
  s.add_dependency "bundler"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
