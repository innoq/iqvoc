require 'turtle_importer'

namespace :import do

  desc "Purges database"
  task :purge => :environment do
    require 'database_cleaner'
    
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  
  desc "Preprocesses import text file (sanitizes Umlauts)"
  task :preprocess => :environment do
    if valid_file_given?
      file = File.expand_path(ENV['FILE'])
      msg_file_found(file)
      
      new_file = File.open(File.join(File.dirname(file), "sanitized_#{Time.now.to_i}.skos"), "w+")
      
      File.foreach(file) do |line|
        if line.size > 2
          triple = line.split(" ", 3)
          
          triple[0] = triple.first.gsub("ß", "sz")
          triple[2] = triple.third.gsub(":", "") if triple.third.match(/^:(".+"\.)$/)
          triple[2] = triple.third.gsub("ß", "sz") unless IqvocGlobal::RdfHelper.is_literal_form?(triple.third)
          
          sanitized_line = ""
          sanitized_line += triple.first
          sanitized_line += " "
          sanitized_line += triple.second
          sanitized_line += " "
          sanitized_line += triple.third
          
          puts sanitized_line

          new_file.puts sanitized_line
        end
      end
      new_file.close
    else
      no_file_given
    end
  end

  desc "Import triples in turtle format"
  task :file => :environment do
    # Rake::Task['import:purge'].invoke
    if valid_file_given?
      file = File.expand_path(ENV['FILE'])
      msg_file_found(file)
      TurtleImporter.new.import(file)
    else
      no_file_given
    end
  end
  
  task :fix_close_matches => :environment do
    if valid_file_given?
      file = File.expand_path(ENV['FILE'])
      msg_file_found(file)
      importer = TurtleImporter.new
      
      File.foreach(file) do |line|
        unless line.blank?
          if line.match(/^:_\d+ skos:closeMatch/)
            puts "Found match: #{line}"
            triple = importer.extract_triple(line)
            Concept.find_by_origin(triple.first).close_matches.create(:value => triple.third.scan(/:(\d*)/).to_s)
          end
        end
      end
    else
      no_file_given
    end
  end
  
  def valid_file_given?
    ENV['FILE'] && File.file?(ENV['FILE'])
  end
  
  def msg_no_file_given
    puts "*** No file given. Use rake import:[task] FILE=xy."
  end
  
  def msg_file_found(file)
    puts "*** Using file #{file}"
  end

end