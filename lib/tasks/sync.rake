namespace :sync do
  task :all, [:host] => :environment do |t, args|
    require 'iqvoc'
    require 'iqvoc/rdf_sync'

    if Iqvoc.config["triplestore.url"] == Iqvoc.config.defaults["triplestore.url"] # XXX: duplicates controller
      puts I18n.t("txt.controllers.triplestore_sync.config_warning")
      fail
    end

    ROOT = args[:host]
    raise(ArgumentError, "host not specified") unless ROOT

    include Rails.application.routes.url_helpers
    default_url_options[:host] = ROOT

    class FakeController
      include Iqvoc::RDFSync::Helper
      delegate :url_helpers, :to => "Rails.application.routes"

      def root_url(*args)
        ROOT
      end

      def view_context(*args)
        default_url_options[:host] = root_url
        view = FakeView.new(Rails.root.join("app", "views"))
        view.controller = self
        return view
      end

      # delegate URL helpers
      def method_missing(name, *args, &block)
        url_helpers.send(name, *args, &block)
      end
    end

    class FakeView < ActionView::Base
      include ApplicationHelper

      attr_accessor :controller

      # delegate URL helpers
      def method_missing(name, *args, &block)
        @controller.send(name, *args, &block)
      end
    end

    puts I18n.t("txt.controllers.triplestore_sync.config_info",
        :target_info => Iqvoc.config["triplestore.url"]) + " (host: #{ROOT})"
    success = FakeController.new.triplestore_syncer.all
    unless success
      puts I18n.t("txt.controllers.triplestore_sync.error")
      fail
    end
  end
end
