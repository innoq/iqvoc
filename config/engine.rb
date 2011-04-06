require 'rails'

# An engine doesn't require it's own dependencies automatically. We also don't
# want the applications to have to do that. 
require 'cancan'
require 'authlogic'
require 'will_paginate'
require 'iq_rdf'
require 'json'

module Iqvoc

  class Engine < Rails::Engine

    # TODO: Is this configuration (s. Application too) still required if iqvoc
    # runs as engine?
    config.additional_js_files  = []
    config.additional_css_files = []

  end

end
