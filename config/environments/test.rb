# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# config.action_controller.session = { :key => "_myapp_session", :secret => "e5e8915f9ca3ac54fae632718ece6929056f95e310332a70d273e2bebe267a36688e0fcda8c8426c50c97ba7752f2d0ccbf8a38d5acb9ade3109ff93e6e10f1e" }

# require 'capybara/rails'
# require 'capybara/session'