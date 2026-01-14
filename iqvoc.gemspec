# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'iqvoc/version'

Gem::Specification.new do |s|
  s.name        = 'iqvoc'
  s.version     = Iqvoc::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Robert Glaser', 'Till Schulte-Coerne', 'Frederik Dohr', 'Marc Jansing']
  s.email       = ['robert.glaser@innoq.com', 'till.schulte-coerne@innoq.com', 'frederik.dohr@innoq.com', 'marc.jansing@innoq.com']
  s.homepage    = 'http://github.com/innoq/iqvoc'
  s.summary     = 'iQvoc'
  s.description = 'iQvoc - a SKOS(-XL) vocabulary management system built on the Semantic Web'
  s.license     = 'Apache-2.0'

  s.add_dependency 'rails', '~> 8.1.2'
  s.add_dependency 'puma'
  s.add_dependency 'bootsnap'
  s.add_dependency 'bundler'
  s.add_dependency 'kaminari'
  s.add_dependency 'authlogic'
  s.add_dependency 'scrypt'
  s.add_dependency 'cancancan'
  s.add_dependency 'iq_rdf'
  s.add_dependency 'json'
  s.add_dependency 'csv'
  s.add_dependency 'rails_autolink'
  s.add_dependency 'faraday', '1.10.3'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'bootstrap_form', '~> 4.0'
  s.add_dependency 'iq_triplestorage'
  s.add_dependency 'nokogiri'
  s.add_dependency 'linkeddata'
  s.add_dependency 'rdf-vocab'
  s.add_dependency 'deep_cloneable'
  s.add_dependency 'apipie-rails'
  s.add_dependency 'maruku'
  s.add_dependency 'database_cleaner'
  s.add_dependency 'delayed_job_active_record'
  s.add_dependency 'carrierwave'
  s.add_dependency 'carrierwave-i18n'
  s.add_dependency 'rack-mini-profiler'
  s.add_dependency 'faucet_pipeline_rails'

  s.files = %w(LICENSE README.md CHANGELOG.md Gemfile Gemfile.lock Rakefile iqvoc.gemspec) +
    Dir.glob('{app,config,db,lib}/**/*')
  s.test_files = Dir['{test}/**/*']
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
end
