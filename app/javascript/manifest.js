// Entry point for the esbuild build script in package.json.
//
// Import order matters here: ./iqvoc/globals must run first so that
// window.jQuery is set before framework/manifest's legacy jQuery plugins,
// which attach to window.jQuery eagerly at import time rather than inside
// a deferred callback.
import './iqvoc/globals'

import Rails from '@rails/ujs'
Rails.start()

import './iqvoc/framework'
import './iqvoc/manifest'
