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
