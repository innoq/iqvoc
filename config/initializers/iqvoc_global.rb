require 'iqvoc_global/common_associations'
require 'iqvoc_global/common_methods'
require 'iqvoc_global/common_scopes'
require 'iqvoc_global/concept_association_extensions'
require 'iqvoc_global/deep_cloning'
require 'iqvoc_global/rdf_helper'

ActiveRecord::Base.send :include, IqvocGlobal::DeepCloning
