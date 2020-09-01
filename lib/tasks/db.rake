namespace :db do

  desc 'Find missing foreign key database indexes'
  task :missing_indexes => :environment do
    c = ActiveRecord::Base.connection

    c.tables.collect do |t|
      columns = c.columns(t).collect(&:name).select { |x| x.ends_with?('_id') || x.ends_with?('_type') }
      indexed_columns = c.indexes(t).collect(&:columns).flatten.uniq
      unindexed = columns - indexed_columns
      unless unindexed.empty?
        puts "#{t}:\n\t #{unindexed.join(", ")}"
      end
    end
  end

  namespace :missing_indexes do
    desc 'Print migration statements for missing foreign key database indexes'
    task :migrators => :environment do
      c = ActiveRecord::Base.connection

      c.tables.collect do |t|
        columns = c.columns(t).collect(&:name).select { |x| x.ends_with?('_id') || x.ends_with?('_type') }
        indexed_columns = c.indexes(t).collect(&:columns).flatten.uniq
        unindexed = columns - indexed_columns
        unindexed.each do |c|
          puts "add_index :#{t}, :#{c}"
        end
      end
    end
  end
end
