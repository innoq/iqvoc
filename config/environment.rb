# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/app/classes )
  
  config.gem "will_paginate"
  config.gem "authlogic"
  config.gem "cancan"
  config.gem "configatron"
  config.gem "iq_rdf"

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
          :session_key => '_iqvoc_server_session',
          :secret => 'b1a59e4f637e3ac20098b0066662ff916c2558fe857fd7cface967a743a68b50caa30d6d2087a91823bb2e94c129bd4160a370cf622d790e3c6ee32fbca8a5fa'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  config.i18n.default_locale = :de

  
  require "configatron"
  # The default URI prefix for RDF data. This will be followed by a document
  # specific shnippet like (specimenType) and the id.
  configatron.rdf_data_uri_prefix = "http://virtuoso.dyndns.org/umthes/"

  # The JDBC driver url for the coinnection to the virtuoso triple store.
  # Login crdentials have to be stored here too. See
  # http://docs.openlinksw.com/virtuoso/VirtuosoDriverJDBC.html#jdbcurl4mat for
  # more details.
  # Example: "jdbc:virtuoso://localhost:1111/UID=dba/PWD=dba"
  # Use nil to disable virtuoso triple synchronization
  configatron.virtuoso_jdbc_driver_url = nil

  # Set up the virtuoso synchronization (which is a triggered pull from the
  # virtuoso server) to be run in a new thread.
  # This is needed in environments where the webserver only runs in a single
  # process/thread (mostly in development environments).
  # When a synchronizaion would be triggered e.g. from a running
  # update action in the UPB, the update would trigger virtuoso to do a HTTP GET
  # back to the UPB to fetch the RDF data. But the only process in the UPB would be
  # blocked by the update... => Deadlock. You can avoid this by using the threaded
  # mode.
  configatron.virtuoso_sync_threaded = false

end

# Der Default ist FALSE!!! Rails speichert somit nur den Klassennamen ohne Namespace in der "type" Spalte!
ActiveRecord::Base.store_full_sti_class = true

REVISION_NUMBER = `svn info`.split("\n")[4][/\d+/].to_i rescue ''
APP_CODENAME = IO.readlines('/usr/share/dict/words')[REVISION_NUMBER].chomp rescue ''

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if instance.error_message.kind_of?(Array)
    %(#{html_tag}<span class="fieldWithErrors">&nbsp;</span>)
  else
    %(#{html_tag}<span class="fieldWithErrors">&nbsp;</span>)
  end
end