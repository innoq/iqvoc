require 'multi_logger'

namespace :iqvoc do

  namespace :import do

    desc 'Imports some ntriples data from a given url (URL=...). Use the parameter NAMESPACE=... to define the default namespace used in your data.'
    task :url => :environment do
      raise "You have to specify an url for the data file to be imported. Example: rake iqvoc:import:url URL=... NAMESPACE=" unless ENV['URL']
      raise "You have to specify a default namespace for the data to be imported. Example: rake iqvoc:import:url URL=... NAMESPACE=" unless ENV['NAMESPACE']

      stdout_logger = Logger.new(STDOUT)
      stdout_logger.level = Logger::INFO
      Iqvoc::SkosImporter.new(open(URI.parse(ENV['URL']).to_s), URI.parse(ENV['NAMESPACE']).to_s, MultiLogger.new(stdout_logger, Rails.logger))
    end

  end

end