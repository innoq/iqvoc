require 'rails'

# An engine doesn't require it's own dependencies automatically. We also don't
# want the applications to have to do that.
require 'cancan'
require 'authlogic'
require 'kaminari'
require 'kaminari-bootstrap'
require 'iq_rdf'
require 'json'
require 'rails_autolink'
require 'sass'
require 'sass-rails'
require 'bootstrap-sass'
require 'bootstrap_form'
require 'protected_attributes'
require 'font-awesome-rails'
require 'uglifier'
require 'apipie-rails'
require 'database_cleaner'
require 'delayed_job_active_record'
require 'carrierwave'

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
      app.config.paths['db/migrate'].concat(Iqvoc::Engine.paths['db/migrate'].existent)
    end
  end

end
