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
  s.license     = "Apache License 2.0"

  s.add_dependency 'rails', '~> 4.0.0'
  s.add_dependency 'bundler'
  s.add_dependency 'kaminari', '0.13.0'
  s.add_dependency 'authlogic'
  s.add_dependency 'cancan'
  s.add_dependency 'iq_rdf', '>= 0.1.13'
  s.add_dependency 'json'
  s.add_dependency 'rails_autolink'
  s.add_dependency 'faraday'
  s.add_dependency 'simple_form'
  s.add_dependency 'sass-rails', '~> 4.0.0'
  s.add_dependency 'bootstrap-sass', '~> 2.3.1.3'
  s.add_dependency 'iq_triplestorage'
  s.add_dependency 'nokogiri'
  s.add_dependency 'linkeddata'
  s.add_dependency 'protected_attributes', '>= 1.0.5'
  s.add_dependency 'font-awesome-rails'
  s.add_dependency 'uglifier', '>= 1.3.0'

  s.files = %w(LICENSE README.md CHANGELOG.md Gemfile Gemfile.lock Rakefile iqvoc.gemspec) +
    Dir.glob("{app,config,db,public,lib,test,vendor}/**/*")
  s.test_files = s.files.grep(%r{^test/})
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
