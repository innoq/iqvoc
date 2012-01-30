require 'rails'

# An engine doesn't require it's own dependencies automatically. We also don't
# want the applications to have to do that.
require 'cancan'
require 'authlogic'
require 'kaminari'
require 'iq_rdf'
require 'json'
require 'rails_autolink'

require 'iqvoc/controller_extensions'

module Iqvoc
  
  class Engine < Rails::Engine
    paths["lib/tasks"] << "lib/engine_tasks"
    
    initializer "iqvoc.mixin_controller_extensions" do |app|
      if const_defined?(:ApplicationController)
        ApplicationController.send(:include, Iqvoc::ControllerExtensions)
      end
    end
    
    initializer "iqvoc.add_assets_to_precompilation" do |app|
      app.config.assets.precompile += Iqvoc.core_assets
    end
  end
  
end
