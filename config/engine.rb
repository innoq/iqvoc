require 'rails'

# An engine doesn't require it's own dependencies automatically. We also don't
# want the applications to have to do that.
require 'cancan'
require 'authlogic'
require 'kaminari'
require 'iq_rdf'
require 'json'
require 'rails_autolink'
require 'fastercsv' if RUBY_VERSION < '1.9'
require 'simple_form'
require 'sass'
require 'sass-rails'

require 'iqvoc/controller_extensions'

module Iqvoc

  class Engine < Rails::Engine
    paths["lib/tasks"] << "lib/engine_tasks"

    initializer "iqvoc.mixin_controller_extensions" do |app|
      if Kernel.const_defined?(:ApplicationController)
        ApplicationController.send(:include, Iqvoc::ControllerExtensions)
      end
    end

    initializer "iqvoc.add_assets_to_precompilation" do |app|
      app.config.assets.precompile += Iqvoc.core_assets
    end

    initializer "iqvoc.load_migrations" do |app|
      # Pull in all the migrations to the application embedding iqvoc
      app.config.paths['db/migrate'] += Iqvoc::Engine.paths['db/migrate'].existent
    end
  end

end
