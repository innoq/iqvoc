## [4.1.0]

  * Concepts hierarchy API (/hierarchy)
  * Support for SKOS notations
  * Adjusted RDF serializations to always include related concepts' pref. labels
  * Fixed MIME type for RDF/XML
  * Editable concept scheme
  * Ruby 2.0 compatibility
  * Dropped support for Ruby 1.8
  * Heroku Cedar support
  * Bugfixes

## [4.0.9]

  * Speed improvements in SKOS importer
  * Preferred labels are now required to be unique
  * Improved handling of a potential "none" language
  * Bugfixes in application template
  * Improved handling of complex comma separated values
  * New view for expired concepts
  * Internal overhaul for collections
  * Lots of bugfixes and improvements throughout

## [4.0.8]

  * Portugese and spanish UI translations (@nitaibezerra)
  * [FIX] Versioning of concepts did not work
  * Bugfixes

## 4.0.7

  * Added support for Sesame as triplestore synchronization target
  * Ditched Ruby 1.8 API compatibility; iQvoc now requires Ruby 1.9+
  * Improved instant search on front page

## 4.0.6

  * Bugfixes for Triplestore Sync and configuration

## 4.0.5

  * Fixed a bug where triple store sync wouldn't load in engine mode
  * More bugfixes

## 4.0.4

  * Triplestore Sync
  * Bugfixes

## 4.0.3

  * New frontpage with quick search
  * SKOS importer now supports blank nodes
  * Bugfixes

## 4.0.2

  * Support for collections in SKOS importer (@fgimenez)
  * Bugfixes

## 4.0.1 (2012-06-20)

  * Rails application template
  * Bugfixes

## 4.0.0 (2012-05-31)

  * Completely redesigned UI
  * Temporarily removed visualization graph<br>
    Needs to be revisited in the near future
  * Bugfixes

## 3.5.7 (2012-05-24)

  * Rankable (weighted) relations
  * Counting concept members in collection hierarchy view
  * Improved heroku support
  * Bugfixes

Please note that this is the last tiny release before we hit 4.0.0.

## 3.5.6 (2012-03-07)

  * Refactored origin (URI slug) generation<br>
    Now supports custom filters to extend generation logic. See more: https://github.com/innoq/iqvoc/blob/master/lib/iqvoc/origin.rb
  * Bugfixes

## 3.5.4 (2012-02-08)

  * Top concepts<br>
    From now on the hierarchical concept view only lists concepts marked as "top term".
    This also includes a default concept scheme and support for top concepts in RDF views.
  * Configurable navigation<br>
    Use `Iqvoc.navigation_items` to inject additional navigation items.
  * Bugfixes

## 3.5.1 (2012-02-01)

 * Bugfixes

## 3.5.0 (2012-02-01)

 * Instance configuration<br>
   You are now able to provide configuration for certain settings in the browser.

## 3.4.0 (2012-01-27)

 * Rails 3.2
 * Bugfixes

## 3.3.4 (2012-01-16)

 * Import SKOS files via the web frontend
 * Bugfixes

## 3.3.3 (2012-01-13)

 * Several asset pipeline related fixes
 * Largely simplified heroku setup
 * Improvements to engine mode

Detailed commit log: https://github.com/innoq/iqvoc/compare/v3.3.0...v3.3.3

## 3.3.0 (2012-01-10)

 * Rails 3.1
 * Asset pipeline<br>
   [Detailed instructions](https://github.com/innoq/iqvoc/wiki/iQvoc-as-a-Rails-Engine)
   on how to use iQvoc as a Rails Engine (including the asset pipeline).

This is a big update. Detailed commit log: https://github.com/innoq/iqvoc/compare/v3.2.6...v3.3.0

## 3.2.6 (2012-01-10)

 * Small fixes
 * Last tiny version before upgrading iQvoc to from Rails 3.0 to 3.1

## 3.2.5 (2011-12-07)

 * Various bugfixes

## 3.2.4 (2011-11-07)

 * Added search functionality for collections
 * Filter search results for concepts and/or collections
 * IE fixes
 * Various bugfixes
 * Ruby 1.9.3

Detailed commit log: https://github.com/innoq/iqvoc/compare/v3.2.3...v3.2.4

## 3.2.3 (2011-08-22)

 * Minor bugfixes
 * Rails 3.0.10

## 3.2.2 (2011-08-17)

 * Various bugfixes
 * Improved unicode character handling in SKOS importer
 * iQvoc is now built on Travis CI (http://www.travis-ci.org)
 * Rails 3.0.9

## 3.2.1 (2011-07-14)

 * Various bugfixes
 * Improved IE7 compatibility

## 3.2.0 (2011-06-22)

 * Optimized eager loading throughout the system
 * Added dashboard pagination
 * Removed default secret token (see README for details)
 * Improved visualization
 * Replaced will_paginate with kaminari
 * Automatic changeNotes now produce dct:creator statements (instead of umt:editor)
 * Complete review of all controllers, models, helpers, tests and views
 * Extensive refactoring
 * Numerous bugfixes

## 3.1.3 (2011-06-09)

* New feature: now showing a visualization of concept relations on a concept page
* Improved performance of full rdf export
* Bugfixes

For a complete list of changes see https://github.com/innoq/iqvoc/compare/v3.1.2...v3.1.3

## 3.1.2 (2011-05-27)

* Fixed search not respecting a set collection filter
* Added support for a none-language (nil) PrefLabel main language setting
* Replaced existing auto-completion widget with a more sane approach
* Several bugfixes

For a complete list of changes see https://github.com/innoq/iqvoc/compare/v3.1.1...v3.1.2

## 3.1.1 (2011-05-23)

* Fixed regression preventing relations from being saved during concept creation
* Minor UI tweaks (fonts, buttons, semantic markup etc.)
* Various bugfixes and internal refactoring

For a complete list of changes see https://github.com/innoq/iqvoc/compare/v3.1.0...v3.1.1

## 3.1.0 (2011-05-16)

* Extended multilanguage support.
  You can now translate concept PrefLabels by switching the main language in the new control bar.
  It's also possible to translate secondary concept relations by switching the secondary language.
* Several UI tweaks: styleable buttons, 2-column layout for concept templates and more.
* Bugfixes

For a complete list of changes see https://github.com/innoq/iqvoc/compare/v3.0.0...v3.1.0

## 3.0.0 (2011-05-10)

iQvoc has undergone major refactorings and architecture changes. It is now Open Source and publicly available.

## 2.3.0

Features

* iQvoc is now Rails 3 compatible. For a full list of fixes see the according commits
