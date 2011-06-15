require 'rails'

# An engine doesn't require it's own dependencies automatically. We also don't
# want the applications to have to do that.
require 'cancan'
require 'authlogic'
require 'kaminari'
require 'iq_rdf'
require 'json'

module Iqvoc

  class Engine < Rails::Engine

    paths.lib.tasks  << "lib/engine_tasks"

    # TODO Will be defined in Rails 3.1 (as well as the tasks in lib/engine_tasks)
    def self.load_seed
      seed_file = Iqvoc::Engine.find_root_with_flag("db").join('db/seeds.rb')
      load(seed_file) if File.exist?(seed_file)
    end

  end

end
