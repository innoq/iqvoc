// Exposes jQuery as a global for the legacy jQuery plugins that expect it
// on `window` (bootstrap-datepicker, typeahead.js, jqtree) rather than
// importing it themselves.
//
// This must be the first thing manifest.js imports: ES module imports
// fully evaluate (module + top-level body) in declaration order before the
// importing module's own body runs, so as long as this module is imported
// before typeahead/bootstrap-datepicker/etc., `window.jQuery` is guaranteed
// to be set by the time their own top-level code (which attaches to it
// eagerly, not inside a deferred callback) executes.
import $ from 'jquery'

window.jQuery = window.$ = $
