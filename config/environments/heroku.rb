# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if Iqvoc.const_defined?(:Application)
  Iqvoc::Application.configure do
    # Settings specified here will take precedence over those in config/environment.rb

    # The production environment is meant for finished, "live" apps.
    # Code is not reloaded between requests
    config.cache_classes = true

    # Full error reports are disabled and caching is turned on
    config.consider_all_requests_local       = false
    config.action_controller.perform_caching = true

    # Specifies the header that your server uses for sending files
    # config.action_dispatch.x_sendfile_header = "X-Sendfile"

    # Disable Rails's static asset server
    # In production, Apache or nginx will already do this
    config.serve_static_assets = true
  
    # Compress JavaScripts and CSS
    config.assets.compress = false

    # Don't fallback to assets pipeline if a precompiled asset is missed
    config.assets.compile = true

    # Generate digests for assets URLs
    config.assets.digest = false

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true

    # Send deprecation notices to registered listeners
    config.active_support.deprecation = :notify
  end
end
