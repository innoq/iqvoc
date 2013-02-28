require 'multi_logger'

namespace :iqvoc do

  namespace :import do

    desc 'Imports some ntriples data from a given url (URL=...). Use the parameter NAMESPACE=... to define the default namespace used in your data.'
    task :url => :environment do
      raise 'You have to specify an url for the data file to be imported. Example: rake iqvoc:import:url URL=... NAMESPACE=' unless ENV['URL']
      raise 'You have to specify a default namespace for the data to be imported. Example: rake iqvoc:import:url URL=... NAMESPACE=' unless ENV['NAMESPACE']

      stdout_logger = Logger.new(STDOUT)
      stdout_logger.level = Logger::INFO
      Iqvoc::SkosImporter.new(open(URI.parse(ENV['URL']).to_s), URI.parse(ENV['NAMESPACE']).to_s, MultiLogger.new(stdout_logger, Rails.logger))
    end

    task :test => :environment do
      str = <<-EOS
<http://www.example.com/animal> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/cow> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/donkey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.example.com/monkey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://not-my-problem.com/me> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept>.
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#prefLabel> "Tier"@de .
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#prefLabel> "Animal"@en .
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#altLabel> "Viehzeug"@de .
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#definition> "Ein Tier ist kein Mensch."@de .
<http://www.example.com/animal> <http://www.w3.org/2008/05/skos#narrower> <http://www.example.com/cow> .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#prefLabel> "Kuh"@de .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#prefLabel> "Cow"@en .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#altLabel> "Rind"@de .
<http://www.example.com/cow> <http://www.w3.org/2008/05/skos#broader> <http://www.example.com/animal> .
<http://www.example.com/donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Esel"@de .
<http://www.example.com/donkey> <http://www.w3.org/2008/05/skos#prefLabel> "Donkey"@en .
<http://www.example.com/donkey> <http://www.w3.org/2008/05/skos#broader> <http://www.example.com/animal> .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#prefLabel> "Affe"@de .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#prefLabel> "Monkey"@en .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#altLabel> "\u00C4ffle"@de .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#altLabel> "Ape"@en .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#broader> <http://www.example.com/animal> .
<http://www.example.com/monkey> <http://www.w3.org/2008/05/skos#exactMatch> <http://dbpedia.org/page/Monkey> .

      EOS

      Iqvoc::RDFAPI.parse_nt(str, 'http://www.example.com/')
    end

  end

end