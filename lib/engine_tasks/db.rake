namespace :iqvoc do
  namespace :db do

    desc "Migrate the database through scripts in db/migrate and update db/schema.rb by invoking db:schema:dump. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
    task :migrate => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(Iqvoc::Engine.find_root_with_flag("db").join("db/migrate"), ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end


    desc "Migrate the database through all scripts in db/migrate of every engine and update db/schema.rb by invoking db:schema:dump. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
    task :migrate_all => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      paths = Rails.application.config.paths["db/migrate"].existent +
          Rails.application.railties.engines.
              map { |e| e.config.paths["db/migrate"] && e.config.paths["db/migrate"].existent }.
              flatten.compact

      puts "Migrating from: " + paths.join(", ")
      ActiveRecord::Migrator.migrate(paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    desc "Load seeds (task is idempotent)"
    task :seed => :environment do
      Iqvoc::Engine.load_seed
    end

    desc "Load seeds from all engines (db/seed tasks should be idempotent)"
    task :seed_all => :environment do
      engines = Rails.application.railties.engines.select { |e|
        e.config.paths["db/seeds"] &&
          e.config.paths["db/seeds"].existent.any?
      }

      engines.select{|e| e.engine_name !~ /^iqvoc_/}.each do |engine|
        puts "There is a non-iQvoc engine (#{engine.engine_name}) having seeds. These seeds are not necessarily idempotent."
        puts "Do you with to (c)ontinue, (i)gnore it or (a)bort?"
        input = nil
        while input !~ /^[cia]$/
          puts "Please try it again [c, i or a]" if input
          STDOUT.flush
          input = STDIN.gets.chomp.downcase
        end
        case input
        when  "i"
          engines.delete(engine)
        when "c"
          # do nothing
        else
          raise "Aborting"
        end
      end

      files = Rails.application.config.paths["db/seeds"].existent +
        engines.map { |e| e.config.paths["db/seeds"].existent }.flatten.compact

      puts "Loading seeds from: " + files.join(", ")
      files.each do |file|
        load(file)
      end
    end

    # invokes the given task for all the namespaces provided as well as for the
    # current application
    # e.g. `invoke_engine_tasks("db:migrate", ["foo", "bar"])` is equivalent to
    # `rake foo:db:migrate bar:db:migrate db:migrate`
    def Iqvoc.invoke_engine_tasks(task_name, engines)
      tasks = engines.map { |engine| "#{engine}:#{task_name}" }
      tasks << task_name
      tasks.each do |task|
        Rake::Task[task].invoke
      end
    end

  end
end
