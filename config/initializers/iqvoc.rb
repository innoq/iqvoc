require 'iqvoc'
require 'iqvoc/version'
require 'iqvoc/versioning'
require 'iqvoc/deep_cloning'
require 'iqvoc/rdf_helper'

ActiveRecord::Base.send :include, Iqvoc::DeepCloning
