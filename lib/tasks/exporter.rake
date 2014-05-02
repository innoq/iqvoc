require 'multi_logger'

namespace :iqvoc do

  desc 'Exports iQvoc data to rdf serialization (turtle, ntriples, rdf/xml)'
  task :export => :environment do
    require 'iqvoc/skos_exporter'

    raise "You have to specify an rdf serialization format (turtle, ntriples or rdf/xml) for the data file to be exported. Example: rake iqvoc:import TYPE=... NAMESPACE=" unless ENV['TYPE']
    raise "You have to specify a default namespace for the data to be imported. Example: rake iqvoc:import TYPE=... NAMESPACE=" unless ENV['NAMESPACE']

    stdout_logger = Logger.new(STDOUT)
    stdout_logger.level = Logger::INFO

    file = File.join('data', "iqvoc_dump.#{ENV['TYPE']}")

    exporter = Iqvoc::SkosExporter.new(file, ENV['TYPE'], ENV['NAMESPACE'], MultiLogger.new(stdout_logger, Rails.logger))
    exporter.run
  end

end
