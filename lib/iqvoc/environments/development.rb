require 'iqvoc'

module Iqvoc::Environments

  def self.setup_development(config)
    # In the development environment your application's code is reloaded on
    # every request.  This slows down response time but is perfect for development
    # since you don't have to restart the web server when you make code changes.
    config.cache_classes = false

    # Log error messages when you accidentally call methods on nil.
    config.whiny_nils = true

    # Show full error reports and disable caching
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    # Don't care if the mailer can't send
    config.action_mailer.raise_delivery_errors = false

    # Print deprecation notices to the Rails logger
    config.active_support.deprecation = :log

    # Only use best-standards-support built into browsers
    config.action_dispatch.best_standards_support = :builtin

    # Do not compress assets
    config.assets.compress = false

    # Expands the lines which load the assets
    config.assets.debug = true

    # Raise exception on mass assignment protection for Active Record models
    config.active_record.mass_assignment_sanitizer = :logger

    # Log the query plan for queries taking more than this (works
    # with SQLite, MySQL, and PostgreSQL)
    config.active_record.auto_explain_threshold_in_seconds = 0.5

    # Prepend all log lines with the following tags
    # config.log_tags = [ :subdomain, :uuid ]

    # The default URI prefix for RDF data. This will be followed by a document
    # specific shnippet like (specimenType) and the id.

    # The JDBC driver url for the coinnection to the virtuoso triple store.
    # Login crdentials have to be stored here too. See
    # http://docs.openlinksw.com/virtuoso/VirtuosoDriverJDBC.html#jdbcurl4mat for
    # more details.
    # Example: "jdbc:virtuoso://localhost:1111/UID=dba/PWD=dba"
    # Use nil to disable virtuoso triple synchronization
    # Rails.application.config.virtuoso_jdbc_driver_url = "jdbc:virtuoso://virtuoso.dyndns.org:1111/UID=iqvoc/PWD=vocpass!/charset=UTF-8"
    config.virtuoso_jdbc_driver_url = nil

    # Set up the virtuoso synchronization (which is a triggered pull from the
    # virtuoso server) to be run in a new thread.
    # This is needed in environments where the webserver only runs in a single
    # process/thread (mostly in development environments).
    # When a synchronizaion would be triggered e.g. from a running
    # update action in the UPB, the update would trigger virtuoso to do a HTTP GET
    # back to the UPB to fetch the RDF data. But the only process in the UPB would be
    # blocked by the update... => Deadlock. You can avoid this by using the threaded
    # mode.
    config.virtuoso_sync_threaded = false
  end

end
