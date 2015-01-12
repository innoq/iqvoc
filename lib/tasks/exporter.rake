namespace :iqvoc do

  desc 'Exports iQvoc data to rdf serialization (turtle, ntriples, rdf/xml)'
  task :export => :environment do

    raise "You have to specify an rdf serialization format (turtle, ntriples or rdf/xml) for the data file to be exported. Example: rake iqvoc:import TYPE=... NAMESPACE=... [FILE=...]" unless ENV['TYPE']
    raise "You have to specify a default namespace for the data to be imported. Example: rake iqvoc:import TYPE=... NAMESPACE=... [FILE=...]" unless ENV['NAMESPACE']

    stdout_logger = Logger.new(STDOUT)
    stdout_logger.level = Logger::INFO

    timestamp = Time.now.strftime("%Y-%m-%d_%H-%M")
    file_path = ENV['FILE'] || Rails.root.join(Iqvoc.export_path, "iqvoc_dump-#{timestamp}.#{ENV['TYPE']}").to_s

    exporter = SkosExporter.new(file_path, ENV['TYPE'], ENV['NAMESPACE'], MultiLogger.new(stdout_logger, Rails.logger))
    exporter.run
  end

end
