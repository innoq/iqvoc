require 'iqvoc'

module Iqvoc::Environments

  def self.setup_production(config)
    # The production environment is meant for finished, "live" apps.
    # Code is not reloaded between requests
    config.cache_classes = true

    # Full error reports are disabled and caching is turned on
    config.consider_all_requests_local = false
    config.action_controller.perform_caching = true

    # Specifies the header that your server uses for sending files
    config.action_dispatch.x_sendfile_header = "X-Sendfile"

    config.autoflush_log = true

    # For nginx:
    # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

    # If you have no front-end server that supports something like X-Sendfile,
    # just comment this out and Rails will serve the files

    # See everything in the log (default is :info)
    # config.log_level = :debug

    # Use a different logger for distributed setups
    # config.logger = SyslogLogger.new

    # Use a different cache store in production
    # config.cache_store = :mem_cache_store

    # Disable Rails's static asset server
    # In production, Apache or nginx will already do this
    config.serve_static_assets = false

    # Compress JavaScripts and CSS
    config.assets.compress = true

    # Don't fallback to assets pipeline if a precompiled asset is missed
    config.assets.compile = false

    # Generate digests for assets URLs
    config.assets.digest = true

    config.assets.precompile += Iqvoc.core_assets

    # Enable serving of images, stylesheets, and javascripts from an asset server
    # config.action_controller.asset_host = "http://assets.example.com"

    # Disable delivery errors, bad email addresses will be ignored
    # config.action_mailer.raise_delivery_errors = false

    # Enable threaded mode
    # config.threadsafe!

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true

    # Send deprecation notices to registered listeners
    config.active_support.deprecation = :notify

    # The JDBC driver URL for the connection to the virtuoso triple store.
    # Login credentials have to be stored here too. See
    # http://docs.openlinksw.com/virtuoso/VirtuosoDriverJDBC.html#jdbcurl4mat for
    # more details.
    # Example: "jdbc:virtuoso://localhost:1111/UID=dba/PWD=dba"
    # Use nil to disable virtuoso triple synchronization
    # Rails.application.config.virtuoso_jdbc_driver_url = "jdbc:virtuoso://virtuoso.dyndns.org:1111/UID=iqvoc/PWD=vocpass!/charset=UTF-8"
    config.virtuoso_jdbc_driver_url = nil

    # Set up the virtuoso synchronization (which is a triggered pull from the
    # virtuoso server) to be run in a new thread.
    # This is needed in environments where the web server only runs in a single
    # process/thread (mostly in development environments).
    # When a synchronization would be triggered e.g. from a running
    # update action in the UPB, the update would trigger virtuoso to do a HTTP GET
    # back to the UPB to fetch the RDF data. But the only process in the UPB would be
    # blocked by the update... => Deadlock. You can avoid this by using the threaded
    # mode.
    config.virtuoso_sync_threaded = false
  end

end
