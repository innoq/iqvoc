namespace :iqvoc do

  desc 'Exports iQvoc data to rdf serialization (turtle, ntriples, rdf/xml)'
  task :export => :environment do

    usage = 'Example: rake iqvoc:export TYPE=... NAMESPACE=... [FILE=...] [LINK=...] [ZIP=true]'
    raise "You have to specify an rdf serialization format (turtle, ntriples or rdf/xml) for the data file to be exported. #{usage}" unless ENV['TYPE']
    raise "You have to specify a default namespace for the data to be exported. #{usage}" unless ENV['NAMESPACE']

    stdout_logger = Logger.new(STDOUT)
    stdout_logger.level = Logger::INFO

    timestamp = Time.now.strftime("%Y-%m-%d_%H-%M")
    zip = ENV['ZIP'] == 'true'
    filename = "#{Iqvoc.export_file_prefix}_dump-#{timestamp}.#{ENV['TYPE']}#{'.zip' if zip}"
    file_path = ENV['FILE'] || Rails.root.join(Iqvoc.export_path, filename).to_s
    file_path += '.zip' if zip && !file_path.end_with?('.zip')

    link_path = ENV['LINK']
    link_path += '.zip' if link_path && zip && !link_path.end_with?('.zip')

    exporter = SkosExporter.new(file_path, ENV['TYPE'], ENV['NAMESPACE'], MultiLogger.new(stdout_logger, Rails.logger), zip: zip, link_path: link_path)
    exporter.run
  rescue => e
    stdout_logger.error "Export failed: #{e.message}"
    raise
  end

end
