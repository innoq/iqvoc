namespace :iqvoc do
  namespace :db do

    desc "Migrate the database through scripts in db/migrate and update db/schema.rb by invoking db:schema:dump. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
    task :migrate => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(Iqvoc::Engine.find_root_with_flag("db").join('db/migrate'), ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
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
