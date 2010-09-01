Iqvoc::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  # The default URI prefix for RDF data. This will be followed by a document
  # specific shnippet like (specimenType) and the id.

  # The JDBC driver url for the coinnection to the virtuoso triple store.
  # Login crdentials have to be stored here too. See
  # http://docs.openlinksw.com/virtuoso/VirtuosoDriverJDBC.html#jdbcurl4mat for
  # more details.
  # Example: "jdbc:virtuoso://localhost:1111/UID=dba/PWD=dba"
  # Use nil to disable virtuoso triple synchronization
  # configatron.virtuoso_jdbc_driver_url = "jdbc:virtuoso://virtuoso.dyndns.org:1111/UID=iqvoc/PWD=vocpass!/charset=UTF-8"
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
