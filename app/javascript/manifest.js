// Central export of iqvoc's own JavaScript, for other apps/gems to import
// (via `import 'iqvoc'`, resolved through package.json's "main"). Does not
// start Rails/UJS - see application.js for that - so it's safe to import
// from a library context without triggering app-level bootstrapping.
//
// Import order matters here: ./iqvoc/globals must run first so that
// window.jQuery is set before framework/manifest's legacy jQuery plugins,
// which attach to window.jQuery eagerly at import time rather than inside
// a deferred callback.
import './iqvoc/globals'
import './iqvoc/framework'
import './iqvoc/manifest'
