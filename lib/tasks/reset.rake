namespace :iqvoc do
  desc 'Resets thesaurus and clear all concepts, collections, labels and (pending) jobs'
  task :reset => :environment do
    stdout_logger = Logger.new(STDOUT)
    stdout_logger.level = Logger::INFO

    DatabaseCleaner.strategy = :truncation, {
        except: Iqvoc.truncation_blacklist
    }
    DatabaseCleaner.clean

    stdout_logger.info I18n.t("txt.views.dashboard.reset_success")
  end
end
